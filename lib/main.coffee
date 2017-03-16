meta = require "../package.json"

module.exports = BridlensisCore =
  config:
    pathToJar:
      title: "Path To JAR"
      description: "Specify the full path to `BridleNSIS.jar`"
      type: "string"
      default: ""
      order: 0
    mutePathWarning:
      title: "Mute Path Warning"
      description: "When enabled, warnings about missing path to `BridleNSIS.jar` will be muted"
      type: "boolean"
      default: false
      order: 1
    customArguments:
      title: "Custom Arguments"
      description: "Specify your preferred [arguments](https://github.com/henrikor2/bridlensis/blob/master/src/main/resources/bridlensis/USAGE) for BridleNSIS"
      type: "string"
      default: ""
      order: 2
    nsisHome:
      title: "NSIS Home"
      description: "NSIS home directory (tried to detect automatically if not specified)"
      type: "string"
      default: ""
      order: 3
    alwaysShowOutput:
      title: "Always Show Output"
      description: "Displays compiler output in console panel. When deactivated, it will only show on errors"
      type: "boolean"
      default: true
      order: 4
    showBuildNotifications:
      title: "Show Build Notifications"
      description: "Displays color-coded notifications that close automatically after 5 seconds"
      type: "boolean"
      default: true
      order: 5
    clearConsole:
      title: "Clear Console"
      description: "When `console-panel` isn't available, build logs will be printed using `console.log()`. This setting clears the console prior to building."
      type: "boolean"
      default: true
      order: 6
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, third-party dependencies will be installed automatically"
      type: "boolean"
      default: true
      order: 7
  subscriptions: null

  activate: (state) ->
    {CompositeDisposable} = require "atom"

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add "atom-workspace", "BridleNSIS:save-&-transpile": => @buildScript(@consolePanel)

    @satisfyDependencies()if atom.config.get("#{meta.name}.manageDependencies") and atom.inSpecMode is false
    @isPathSetup() if atom.config.get("#{meta.name}.mutePathWarning") is false

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  satisfyDependencies: () ->
    require("atom-package-deps").install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  isPathSetup: () ->
    { access, constants} = require "fs"

    pathToJar = atom.config.get("#{meta.name}.pathToJar")

    access pathToJar, constants.R_OK | constants.W_OK, (error) ->
      if error
        notification = atom.notifications.addWarning(
          "**#{meta.name}**: No valid \`BridleNSIS.jar\` was specified in your settings",
          dismissable: true,
          buttons: [
            {
              text: 'Open Settings'
              onDidClick: ->
                atom.workspace.open("atom://config/packages/#{meta.name}");
                notification.dismiss();
            },
            {
              text: 'Ignore',
              onDidClick: ->
                atom.config.set("#{meta.name}.mutePathWarning", true);
                notification.dismiss();
            }
          ]
        )

  consumeConsolePanel: (@consolePanel) ->

  buildScript: (consolePanel) ->
    {spawn} = require "child_process"

    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith "source.nsis.bridle"
      editor.save() if editor.isModified()

      bridleJar = atom.config.get("#{meta.name}.pathToJar")
      defaultArguments = ["-jar", bridleJar]

      if atom.config.get("#{meta.name}.customArguments").length > 0
        customArguments = atom.config.get("#{meta.name}.customArguments").trim().split(" ")
      else
        customArguments = []

      if atom.config.get("#{meta.name}.nsisHome").length > 0 and customArguments.indexOf("-n") == -1
        customArguments.push("-n")
        customArguments.push(atom.config.get("#{meta.name}.nsisHome"))

      customArguments.push(script)
      args = defaultArguments.concat(customArguments)

      try
        consolePanel.clear()
      catch
        console.clear() if atom.config.get("#{meta.name}.clearConsole")

      # Let's go
      bridleCmd = spawn "java", args
      hasError = false

      bridleCmd.stdout.on "data", (data) ->
        try
          consolePanel.log(data.toString()) if atom.config.get("#{meta.name}.alwaysShowOutput")
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
          return atom.notifications.addSuccess("Transpiled successfully", dismissable: false) if atom.config.get("#{meta.name}.showBuildNotifications")

        return atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get("#{meta.name}.showBuildNotifications")
    else
      # Something went wrong
      atom.beep()
