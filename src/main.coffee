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
    { CompositeDisposable } = require "atom"
    { isPathSetup, satisfyDependencies } = require "./util"
    { transpile } = require "./bridlensis"

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add "atom-workspace", "BridleNSIS:save-&-transpile": => transpile(@consolePanel)

    satisfyDependencies(true) if atom.config.get("language-bridlensis.manageDependencies") is true
    isPathSetup() if atom.config.get("language-bridlensis.mutePathWarning") is false

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  consumeConsolePanel: (@consolePanel) ->
