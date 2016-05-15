# Dependencies
{exec} = require 'child_process'

module.exports = BridlensisCore =
  subscriptions: null
  which: null
  prefix: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'BridleNSIS:save-&-compile': => @buildScript()

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()
    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsis.bridle'
      editor.save()

      @getPath (stdout) ->
        bridleJar  = atom.config.get('language-bridlensis.pathToJar')
        if !bridleJar?
          atom.notifications.addError("**language-bridlensis**: no valid JAR file specified in your config", dismissable: false)
          return

        exec "\"java\" -jar \"#{bridleJar}\" \"#{script}\"", (error, stdout, stderr) ->
          if error isnt null
            # bridleJar error from stdout, not error!
            atom.notifications.addError(script, detail: error, dismissable: true)
          else
            atom.notifications.addSuccess("Compiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    @getPlatform()

    # Find Java
    exec "\"#{@which}\" java", (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**language-bridlensis**: Java is not in your `PATH` [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      else
        callback stdout
      return

  getPlatform: ->
    os = require 'os'

    if os.platform() is 'win32'
      @which  = "where"
      @prefix = "/"
    else
      @which  = "which"
      @prefix = "-"
