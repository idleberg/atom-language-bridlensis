meta = require '../package.json'

# Dependencies
{spawn} = require 'child_process'

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
      description: "Specify your preferred [arguments](https://github.com/henrikor2/bridlensis/blob/master/src/main/resources/bridlensis/USAGE) for BridleNSIS"
      type: "string"
      default: ""
      order: 1
    nsisHome:
      title: "NSIS Home"
      description: "NSIS home directory (tried to detect automatically if not specified)"
      type: "string"
      default: ""
      order: 2
    alwaysShowOutput:
      title: "Always Show Output"
      description: "Displays compiler output in console panel. When deactivated, it will only show on errors"
      type: "boolean"
      default: true
      order: 3
    showBuildNotifications:
      title: "Show Build Notifications"
      description: "Displays color-coded notifications that close automatically after 5 seconds"
      type: "boolean"
      default: true
      order: 4
    clearConsole:
      title: "Clear Console"
      description: "When `console-panel` isn't available, build logs will be printed using `console.log()`. This setting clears the console prior to building."
      type: "boolean"
      default: true
      order: 5
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, this will automatically install third-party dependencies"
      type: "boolean"
      default: true
      order: 6
  subscriptions: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'BridleNSIS:save-&-transpile': => @buildScript(@consolePanel)

    if atom.config.get('language-bridlensis.manageDependencies')
      @satisfyDependencies()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  satisfyDependencies: () ->
    require('atom-package-deps').install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  consumeConsolePanel: (@consolePanel) ->

  buildScript: (consolePanel) ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.nsis.bridle'
      editor.save() if editor.isModified()

      bridleJar = atom.config.get('language-bridlensis.pathToJar')

      if not bridleJar
        notification = atom.notifications.addWarning(
          "**#{meta.name}**: No valid `BridleNSIS.jar` was specified in your settings"
          dismissable: true
          buttons: [
            {
              text: 'Open Settings'
              onDidClick: ->
                atom.workspace.open("atom://config/packages/#{meta.name}")
                notification.dismiss()
            }
          ]
        )
        return

      defaultArguments = ["-jar", bridleJar]

      if atom.config.get('language-bridlensis.customArguments').length > 0
        customArguments = atom.config.get('language-bridlensis.customArguments').trim().split(" ")
      else
        customArguments = []

      if atom.config.get('language-bridlensis.nsisHome').length > 0 and customArguments.indexOf('-n') == -1
        customArguments.push("-n")
        customArguments.push(atom.config.get('language-bridlensis.nsisHome'))

      customArguments.push(script)
      args = defaultArguments.concat(customArguments)

      try
        consolePanel.clear()
      catch
        console.clear() if atom.config.get('language-bridlensis.clearConsole')

      # Let's go
      bridleCmd = spawn "java", args
      hasError = false

      bridleCmd.stdout.on 'data', (data) ->
        try
          consolePanel.log(data.toString()) if atom.config.get('language-bridlensis.alwaysShowOutput')
        catch
          console.log(data.toString())

      bridleCmd.stderr.on 'data', (data) ->
        hasError = true
        try
          consolePanel.error(data.toString())
        catch
          console.error(data.toString())

      bridleCmd.on 'close', ( errorCode ) ->
        if errorCode is 0 and hasError is false
          return atom.notifications.addSuccess("Transpiled successfully", dismissable: false) if atom.config.get('language-bridlensis.showBuildNotifications')

        return atom.notifications.addError("Transpile failed", dismissable: false) if atom.config.get('language-bridlensis.showBuildNotifications')
    else
      # Something went wrong
      atom.beep()
