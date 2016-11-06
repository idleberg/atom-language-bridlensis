# Dependencies
{exec} = require 'child_process'
os = require 'os'

# Set platform defaults
if os.platform() is 'win32'
  which  = "where"
else
  which  = "which"

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
    @subscriptions.add atom.commands.add 'atom-workspace', 'BridleNSIS:save-&-compile': => @buildScript()

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

        customArguments = atom.config.get('language-bridlensis.customArguments').trim().split(" ")
        customArguments.push("\"#{script}\"")
        customArguments.join(" ")

        exec "\"java\" -jar \"#{bridleJar}\" #{customArguments}", (error, stdout, stderr) ->
          if error isnt null
            # bridleJar error from stdout, not error!
            atom.notifications.addError("**#{script}**", detail: error, dismissable: true)
          else
            atom.notifications.addSuccess("Compiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->

    # Find Java
    exec "\"#{which}\" java", (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**language-bridlensis**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      else
        callback stdout
      return
