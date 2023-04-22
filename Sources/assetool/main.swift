//
// assetool
//
// Created by Yubo Qin on 1/7/22.
// 

import Foundation
import ArgumentParser
import AssetKit

struct Assetool: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "assetool",
        abstract: "A command line tool for generating image assets",
        version: "1.2.0",
        subcommands: [Icon.self, Image.self],
        defaultSubcommand: Icon.self)

}

extension Assetool {

    struct Icon: ParsableCommand {

        @Argument(help: "Path to the input image")
        var input: String

        @Option(name: .shortAndLong, help: "Path of the output folder. If empty, will use terminal current path")
        var output: String?

        @Option(name: .shortAndLong, help: "Platforms to include in the generated icon set")
        var platforms: String = "ios,macos,watchos"

        @Flag(name: .shortAndLong, help: "Generates single size for iOS and watchOS, suited for newer Xcode")
        var universal: Bool = false

        static var configuration = CommandConfiguration(
            abstract: "Generates icon set for Apple platforms. Multiple platform idioms can be merged into one single appiconset",
            discussion: "<platforms> flag: Valid values are: 'ios', 'mac', 'macos', 'watch', 'watchos'. To generate an icon set with multiple platform idioms, multiple values should be separated by comma, e.g. 'ios,mac,watch'")

        func run() throws {
            let parsedPlatforms: [AssetKit.Platform] = platforms
                .split(separator: ",")
                .compactMap { parsePlatform(from: String($0)) }

            AssetKit.generateIconSet(
                inputPath: input,
                outputPath: output ?? FileManager.default.currentDirectoryPath,
                platforms: Set(parsedPlatforms),
                prefersUniversal: universal)
        }

        private func parsePlatform(from input: String) -> AssetKit.Platform? {
            switch input.lowercased() {
            case "ios":
                return .ios
            case "mac", "macos":
                return .macos
            case "watch", "watchos":
                return .watchos
            default:
                return nil
            }
        }

    }

}

extension Assetool {

    struct Image: ParsableCommand {

        @Argument(help: "Path to the input image")
        var input: String

        @Option(name: .shortAndLong, help: "Path of the output folder. If empty, will use terminal current path")
        var output: String?

        @Option(name: .long, help: "Width of the @1x image. If empty, will use image's original width as @3x width")
        var width: Float?

        @Option(name: .long, help: "Height of the @1x image. If empty, will use image's original height as @3x height")
        var height: Float?

        static var configuration = CommandConfiguration(
            abstract: "Generates image set for Apple platforms")

        func run() throws {

            func parseOptionalFloat(_ number: Float?) -> CGFloat? {
                if let number = number {
                    return CGFloat(number)
                }
                return nil
            }

            AssetKit.generateImageSet(
                inputPath: input,
                outputPath: output ?? FileManager.default.currentDirectoryPath,
                width: parseOptionalFloat(width),
                height: parseOptionalFloat(height))
        }

    }

}

Assetool.main()
