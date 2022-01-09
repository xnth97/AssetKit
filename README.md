# AssetKit

A command line tool and Swift package for generating image assets for Apple platforms.

# CLI

## Installation

Please download prebuilt binaries from [Releases](https://github.com/xnth97/AssetKit/releases).

## Usage

The CLI `assetool` supports subcommands for generating both `.appiconset` and `.imageset`. Default subcommand is `icon`.

### Icon

```
assetool <input> [-o <output>] [-p <platforms>]
```

`-o, --output <output>`: Path of the output folder. If empty, will use current path of terminal.

`-p, --platforms <platforms>`: Valid values are: `ios`, `iphone`, `ipad`, `mac`, `car`. You can also generate an icon set with multiple platform idioms by sending a string of multiple values separated by comma, e.g. `ios,mac,watch`.

### Image

```
assetool image <input> [-o <output>] [--width <width>] [--height <height>]
```

`--width <width>` and `--height <height>`: @1x width or height of the exported image set. If empty, will use the original width/height as @3x size.

# Package

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/xnth97/AssetKit", from: "1.0.0"),
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
