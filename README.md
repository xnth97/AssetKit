# AssetKit

A command line tool and Swift package for generating image assets for Apple platforms.

# GUI

[![](/Images/badge.svg)](https://apps.apple.com/us/app/assetool/id1613455194?l=zh&mt=12)

`Assetool` is a SwiftUI app built on top of `AssetKit`. Free download from Mac App Store.

![](/Images/demo.png)

# CLI

## Installation

### Prebuilt

Please download prebuilt binaries from [Releases](https://github.com/xnth97/AssetKit/releases).

### Build

1. Clone this repo, `cd` into the base directory.
2. Run `swift build -c release`.
3. Binaries are located in `.build/release`.

## Usage

The CLI `assetool` supports subcommands for generating both `.appiconset` and `.imageset`. Default subcommand is `icon`.

### Icon

```
assetool <input> [-o <output>] [-p <platforms>] [--universal]
```

`-o, --output <output>`: Path of the output folder. If empty, will use current path of terminal.

`-p, --platforms <platforms>`: Valid values are: `ios`, `mac`, `macos`, `watch`, `watchos`. You can also generate an icon set with multiple platform idioms by sending a string of multiple values separated by comma, e.g. `ios,mac,watch`.

`-u, --universal` Generates single size for iOS and watchOS, suited for newer Xcode.

### Image

```
assetool image <input> [-o <output>] [--width <width>] [--height <height>]
```

`--width <width>` and `--height <height>`: @1x width or height of the exported image set. If empty, will use the original width/height as @3x size.

### OSX Iconset

The `osx-iconset` subcommand generates OS X `.iconset` format. See [Icon Set Type](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/IconSetType.html) for details.

```
assetool osx-iconset <input> [-o <output>]
```

# Package

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/xnth97/AssetKit", from: "1.2.1"),
],
```

## Usage

### Icon

```swift
AssetKit.generateIconSet(
    inputPath: input,
    outputPath: output,
    platforms: [.ios, .mac])
```

### Image

```swift
AssetKit.generateImageSet(
    inputPath: input,
    outputPath: output,
    width: width,
    height: height)
```

# License

The project is released under MIT license. Please see [LICENSE](LICENSE) for full terms.
