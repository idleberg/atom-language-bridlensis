# BridleNSIS for Atom

[![apm](https://img.shields.io/apm/l/language-bridlensis.svg?style=flat-square)](https://atom.io/packages/language-bridlensis)
[![apm](https://img.shields.io/apm/v/language-bridlensis.svg?style=flat-square)](https://atom.io/packages/language-bridlensis)
[![apm](https://img.shields.io/apm/dm/language-bridlensis.svg?style=flat-square)](https://atom.io/packages/language-bridlensis)
[![Travis](https://img.shields.io/travis/idleberg/atom-language-bridlensis.svg?style=flat-square)](https://travis-ci.org/idleberg/atom-language-bridlensis)
[![David](https://img.shields.io/david/dev/idleberg/atom-language-bridlensis.svg?style=flat-square)](https://david-dm.org/idleberg/atom-language-bridlensis#info=devDependencies)
[![Gitter](https://img.shields.io/badge/chat-Gitter-ff69b4.svg?style=flat-square)](https://gitter.im/NSIS-Dev/Atom)

Atom language support for [BridleNSIS](https://github.com/henrikor2/bridlensis), consisting of grammar and snippets

## Installation

### apm

* Install package `apm install language-bridlensis` (or use the GUI)

### GitHub

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Mac OS X & Linux
$ cd ~/.atom/packages/
```

Clone repository as `language-bridlensis`:

`$ git clone https://github.com/idleberg/atom-language-bridlensis language-bridlensis`

## Usage

To avoid interference with vanilla NSIS, consider using the file-extensions `.bridle-nsis` and `.bridle-nsh`. Alternatively, you can set the syntax to *“BridleNSIS”* (`source.nsis.bridle`) manually.

### Building

As of recently, this package contains a rudimentary build system to translate BridleNSIS code. To do so, select *BridleNSIS: Save & Compile”* from the [command-palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette) or use the keyboard shortcut.

Make sure to specify the path for `BridleNSIS.jar` in your `config.cson`.

**Example:**

```cson
"language-bridlensis":
  pathToJar: "/full/path/to/bridle.jar"
```

#### Third-party packages

Should you already use the [build](https://atom.io/packages/build) package, you can install the [build-bridlensis](https://atom.io/packages/build-bridlensis) provider to build your code.

## License

This work is dual-licensed under [The MIT License](https://opensource.org/licenses/MIT) and the [GNU General Public License, version 2.0](https://opensource.org/licenses/GPL-2.0)

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atom-language-bridlensis) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`