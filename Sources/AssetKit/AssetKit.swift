//
//  AssetKit.swift
//  AssetKit
//
//  Created by Yubo Qin on 1/6/22.
//

import Foundation
import AppKit

public struct AssetKit {

    public enum Platform: String, CaseIterable {
        case ios
        case macos
        case watchos
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
        try? generator.generateImageSet(
            inputPath: inputPath,
            outputPath: outputPath,
            width: width,
            height: height)
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
        try? generator.generateImageSet(
            input: input,
            filename: filename,
            outputPath: outputPath,
            width: width,
            height: height)
    }

    /// Generates `.appiconset` with a given input image.
    /// - Parameters:
    ///   - inputPath: Path to input image.
    ///   - outputPath: Path to output folder.
    ///   - platforms: Platform idioms that need to be included in the generated icon set.
    ///   - prefersUniversal: Generates single size for iOS and watchOS, suited for newer Xcode.
    public static func generateIconSet(inputPath: String,
                                       outputPath: String,
                                       platforms: Set<Platform> = [.ios],
                                       prefersUniversal: Bool = false) {
        try? generator.generateIconSet(
            inputPath: inputPath,
            outputPath: outputPath,
            platforms: platforms,
            prefersUniversal: prefersUniversal)
    }

    /// Generates `.appiconset` with a given input image.
    /// - Parameters:
    ///   - input: Input `NSImage` image.
    ///   - outputPath: Path to output folder.
    ///   - platforms: Platform idioms that need to be included in the generated icon set.
    ///   - prefersUniversal: Generates single size for iOS and watchOS, suited for newer Xcode.
    public static func generateIconSet(input: NSImage,
                                       outputPath: String,
                                       platforms: Set<Platform> = [.ios],
                                       prefersUniversal: Bool = false) {
        try? generator.generateIconSet(
            input: input,
            outputPath: outputPath,
            platforms: platforms,
            prefersUniversal: prefersUniversal)
    }

    /// Generates a traditional OSX `icon.iconset`.
    /// See `https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/IconSetType.html`
    /// - Parameters:
    ///   - inputPath: Input path to image.
    ///   - outputPath: Path to output folder.
    public static func generateOSXIconSet(inputPath: String,
                                          outputPath: String) {
        try? generator.generateOSXIconSet(inputPath: inputPath, outputPath: outputPath)
    }

    /// Generates a traditional OSX `icon.iconset`.
    /// See `https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/IconSetType.html`
    /// - Parameters:
    ///   - inputPath: Input `NSImage` image.
    ///   - outputPath: Path to output folder.
    public static func generateOSXIconSet(input: NSImage,
                                          outputPath: String) {
        try? generator.generateOSXIconSet(input: input, outputPath: outputPath)
    }

}
