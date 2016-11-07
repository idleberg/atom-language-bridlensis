# Dependencies
{spawn} = require 'child_process'
os = require 'os'
module.exports = BridlensisCore =
  config:
    pathToJar:
      title: "Path To JAR"
      description: "Specify the full path to `BridleNSIS.jar`"
      type: "string"
      default: ""
      order: 0
    customArguments:
      title: "Custom Arguments"
      description: "Specify your preferred arguments for BridleNSIS"
      type: "string"
      default: ""
      order: 1
  subscriptions: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'BridleNSIS:save-&-transpile': => @buildScript()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**language-bridlensis**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsis.bridle'
      editor.save()

      @getPath (stdout) ->
        bridleJar  = atom.config.get('language-bridlensis.pathToJar')
        
        if not bridleJar
          atom.notifications.addError("**language-bridlensis**: no valid `BridleNSIS.jar` specified in your config", dismissable: false)
          return

        defaultArguments = ["-jar", bridleJar]
        customArguments = atom.config.get('language-bridlensis.customArguments').trim().split(" ")

        if os.platform() is 'win32'
          customArguments.push("\"#{script}\"")
        else
          customArguments.push(script)

        args = defaultArguments.concat(customArguments)
        bridleCmd = spawn('java', args);

        bridleCmd.stderr.on 'data', (data) ->
          atom.notifications.addError("Transpiling failed", detail: data, dismissable: true)
          return

        bridleCmd.stdout.on 'data', (data) ->
          atom.notifications.addSuccess("Transpiled successfully", detail: data, dismissable: false)
          return

    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    if os.platform() is 'win32'
      whichJava = spawn('where', ['java']);
    else
      whichJava = spawn('which', ['java']);

    # Find Java
    whichJava.stderr.on 'data', (data) ->
      atom.notifications.addError("**language-bridlensis**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      return

    whichJava.stdout.on 'data', (data) ->
      callback data
      return
