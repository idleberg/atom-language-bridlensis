module.exports = BridleNsis =

  transpile: (consolePanel) ->
    { spawn } = require "child_process"
    { notifyOnSucess } = require "./util"

    require("./ga").sendEvent "bridlensis", "Save & Transpile"

    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**language-bridlensis**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope is "source.nsis" or scope is "source.nsis.bridle"
      editor.save().then ->
        bridleJar = atom.config.get("language-bridlensis.pathToJar")
        defaultArguments = ["-jar", bridleJar]

        if atom.config.get("language-bridlensis.customArguments").length > 0
          customArguments = atom.config.get("language-bridlensis.customArguments").trim().split(" ")
        else
          customArguments = []

        if atom.config.get("language-bridlensis.nsisHome").length > 0 and customArguments.indexOf("-n") == -1
          customArguments.push("-n")
          customArguments.push(atom.config.get("language-bridlensis.nsisHome"))

        customArguments.push(script)
        args = defaultArguments.concat(customArguments)

        try
          consolePanel.clear()
        catch
          console.clear() if atom.config.get("language-bridlensis.clearConsole")

        # Let's go
        bridleCmd = spawn "java", args
        hasError = false

        bridleCmd.stdout.on "data", (data) ->
          if data.indexOf("Exit Code:") isnt -1
            hasError = true

          try
            consolePanel.log(data.toString()) if atom.config.get("language-bridlensis.alwaysShowOutput")
          catch
            console.log(data.toString())

        bridleCmd.stderr.on "data", (data) ->
          hasError = true
          try
            consolePanel.error(data.toString())
          catch
            console.error(data.toString())

        bridleCmd.on "close", ( errorCode ) ->
          if errorCode is 0 and hasError is false
            return notifyOnSucess() if atom.config.get("language-bridlensis.showBuildNotifications")

          return atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get("language-bridlensis.showBuildNotifications")
    else
      # Something went wrong
      atom.beep()
