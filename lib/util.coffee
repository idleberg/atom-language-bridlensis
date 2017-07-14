module.exports = Util =
  isPathSetup: () ->
    { access, constants} = require "fs"

    pathToJar = atom.config.get("language-bridlensis.pathToJar")

    access pathToJar, constants.R_OK | constants.W_OK, (error) ->
      if error
        notification = atom.notifications.addWarning(
          "**language-bridlensis**: No valid \`BridleNSIS.jar\` was specified in your settings",
          dismissable: true,
          buttons: [
            {
              text: 'Open Settings'
              onDidClick: ->
                atom.workspace.open("atom://config/packages/language-bridlensis")
                notification.dismiss()
            },
            {
              text: 'Ignore',
              onDidClick: ->
                atom.config.set("language-bridlensis.mutePathWarning", true)
                notification.dismiss()
            }
          ]
        )

  notifyOnSucess: ->
    notification = atom.notifications.addSuccess(
      "Transpiled successfully",
      dismissable: true,
      buttons: [
        {
          text: 'Open'
          onDidClick: ->
            Util.openScript()
            notification.dismiss()
        }
        {
          text: 'Cancel'
          onDidClick: ->
            notification.dismiss()
        }
      ]
    ) if atom.config.get("language-bridlensis.showBuildNotifications")

  openScript: ->
    { basename, dirname, extname, join } = require "path"
    doc = atom.workspace.getActiveTextEditor().buffer?.file.path
    dirName = dirname(doc)
    extName = extname(doc)
    baseName = basename(doc, extName)

    if extName is ".nsi"
      outName = baseName + ".bnsi"
    else if extName is ".nsh"
      outName = baseName + ".bnsh"
    else # because BridleNSIS is kinda buggy
      outName = baseName + ".b" + extName.substr(extName)

    nsisFile = join(dirName, outName)

    atom.workspace.open(nsisFile)

  satisfyDependencies: () ->
    meta = require "../package.json"
    require("atom-package-deps").install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)
