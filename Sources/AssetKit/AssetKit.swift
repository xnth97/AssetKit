//
//  AssetKit.swift
//  AssetKit
//
//  Created by Yubo Qin on 1/6/22.
//

import Foundation
import AppKit

public struct AssetKit {

    public enum Platform: String {
        case iphone
        case ipad
        case ios
        case car
        case watch
        case mac
    }

    private static let generator = AssetGenerator()

    /// Generates `.imageset` with a given input image.
    /// - Parameters:
    ///   - inputPath: Path to input image.
    ///   - outputPath: Path to output folder.
    ///   - width: @1x width of output image. If left empty, will use image original size as @3x.
    ///   - height: @1x height of output image. If let empty, will use image original height as @3x.
    public static func generateImageSet(inputPath: String,
                                        outputPath: String,
                                        width: CGFloat? = nil,
                                        height: CGFloat? = nil) {
        try? generator.generateImageSet(inputPath: inputPath, outputPath: outputPath, width: width, height: height)
    }

    /// Generates `.imageset` with a given input image.
    /// - Parameters:
    ///   - input: Input `NSImage` image.
    ///   - filename: File name of generated image set.
    ///   - outputPath: Path to output folder.
    ///   - width: @1x width of output image. If left empty, will use image original size as @3x.
    ///   - height: @1x height of output image. If let empty, will use image original height as @3x.
    public static func generateImageSet(input: NSImage,
                                        filename: String,
                                        outputPath: String,
                                        width: CGFloat? = nil,
                                        height: CGFloat? = nil) {
        try? generator.generateImageSet(input: input, filename: filename, outputPath: outputPath, width: width, height: height)
    }

    /// Generates `.appiconset` with a given input image.
    /// - Parameters:
    ///   - inputPath: Path to input image.
    ///   - outputPath: Path to output folder.
    ///   - platforms: Platform idioms that need to be included in the generated icon set.
    public static func generateIconSet(inputPath: String,
                                       outputPath: String,
                                       platforms: [Platform] = [.ios]) {
        try? generator.generateIconSet(inputPath: inputPath, outputPath: outputPath, platforms: platforms)
    }

    /// Generates `.appiconset` with a given input image.
    /// - Parameters:
    ///   - input: Input `NSImage` image.
    ///   - outputPath: Path to output folder.
    ///   - platforms: Platform idioms that need to be included in the generated icon set.
    public static func generateIconSet(input: NSImage,
                                       outputPath: String,
                                       platforms: [AssetKit.Platform] = [.ios]) {
        try? generator.generateIconSet(input: input, outputPath: outputPath, platforms: platforms)
    }

}
