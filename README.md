# BridleNSIS for Atom

[![apm](https://img.shields.io/apm/l/language-bridlensis.svg?style=flat-square)](https://atom.io/packages/language-bridlensis)
[![apm](https://img.shields.io/apm/v/language-bridlensis.svg?style=flat-square)](https://atom.io/packages/language-bridlensis)
[![apm](https://img.shields.io/apm/dm/language-bridlensis.svg?style=flat-square)](https://atom.io/packages/language-bridlensis)
[![Travis](https://img.shields.io/travis/idleberg/atom-language-bridlensis.svg?style=flat-square)](https://travis-ci.org/idleberg/atom-language-bridlensis)
[![David](https://img.shields.io/david/dev/idleberg/atom-language-bridlensis.svg?style=flat-square)](https://david-dm.org/idleberg/atom-language-bridlensis?type=dev)
[![Gitter](https://img.shields.io/badge/chat-Gitter-ed1965.svg?style=flat-square)](https://gitter.im/NSIS-Dev/Atom)

Atom language support for [BridleNSIS](https://github.com/henrikor2/bridlensis), including grammar, snippets and build system

## Installation

### apm

* Install package `apm install language-bridlensis` (or use the GUI)

### Using Git

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Linux & macOS
$ cd ~/.atom/packages/
```

Clone repository as `language-bridlensis`:

```bash
$ git clone https://github.com/idleberg/atom-language-bridlensis language-bridlensis
```

### Package Dependencies

This package automatically installs third-party packages it depends on. You can prevent this by disabling the *Manage Dependencies* option in the package settings.

## Usage

To avoid interference with vanilla NSIS, consider using the file-extensions `.bridle-nsis` and `.bridle-nsh`. Alternatively, you can set the syntax to *“BridleNSIS”* (`source.nsis.bridle`) manually.

### Building

As of recently, this package contains a rudimentary build system to transpile BridleNSIS code. To do so, select *BridleNSIS: Save & Transpile”* from the [command-palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette) or use the keyboard shortcut.

Make sure to specify the path for `BridleNSIS.jar` in your Atom [configuration](http://flight-manual.atom.io/using-atom/sections/basic-customization/#_global_configuration_settings).

**Example:**

```cson
"language-bridlensis":
  pathToJar: "%PROGRAMFILES(X86)%\\BridleNSIS\\BridleNSIS-0.4.1.jar"
```

#### Third-party packages

Should you already use the [build](https://atom.io/packages/build) package, you can install the [build-bridlensis](https://atom.io/packages/build-bridlensis) provider to build your code.

## License

This work is dual-licensed under [The MIT License](https://opensource.org/licenses/MIT) and the [GNU General Public License, version 2.0](https://opensource.org/licenses/GPL-2.0)

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atom-language-bridlensis) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`
