//
//  AssetGenerator.swift
//  AssetKit
//
//  Created by Yubo Qin on 1/7/22.
//

import Foundation
import AppKit
import ImageIO

public class AssetGenerator {

    public enum AssetGeneratorError: Error {
        case configError
        case dataSourceError
        case resourceError
        case resizeError
    }

    public struct ResizeConfiguration {
        let width: Int
        let height: Int
        let filename: String
    }

    public func generateIconSet(input: NSImage,
                                outputPath: String,
                                platforms: Set<AssetKit.Platform> = [.ios],
                                prefersUniversal: Bool = true) throws {
        let imageSource = try AssetUtils.createCGImageSource(from: input)
        try generateIconSet(
            imageSource: imageSource,
            outputPath: outputPath,
            platforms: platforms,
            prefersUniversal: prefersUniversal)
    }

    public func generateIconSet(inputPath: String,
                                outputPath: String,
                                platforms: Set<AssetKit.Platform> = [.ios],
                                prefersUniversal: Bool = true) throws {
        let imageSource = try AssetUtils.createCGImageSource(from: inputPath)
        try generateIconSet(
            imageSource: imageSource,
            outputPath: outputPath,
            platforms: platforms,
            prefersUniversal: prefersUniversal)
    }

    private func generateIconSet(imageSource: CGImageSource,
                                 outputPath: String,
                                 platforms: Set<AssetKit.Platform> = [.ios],
                                 prefersUniversal: Bool) throws {
        var config = try AssetUtils.loadResourceJson(filename: "icon_contents")

        let iconSetFileName = "AppIcon.appiconset"
        let outputFolder = URL(fileURLWithPath: outputPath).appendingPathComponent(iconSetFileName)
        try AssetUtils.createDirectoryIfNeeded(url: outputFolder)

        var resizeConfigs: [ResizeConfiguration] = []
        var filteredImageConfigs: [[String: Any]] = []
        guard let imageConfigs = config["images"] as? [[String: Any]] else {
            throw AssetGeneratorError.configError
        }

        for imageConfig in imageConfigs {
            guard let configPlatform = getPlatform(from: imageConfig),
                  platforms.contains(configPlatform) else {
                continue
            }

            /// If prefers universal, skip image config parsing.
            if prefersUniversal, configPlatform == .ios || configPlatform == .watchos {
                continue
            }

            let scaleStr = (imageConfig["scale"] as? String)?.prefix(1) ?? "1"
            guard let scale = Float(scaleStr),
                  let sizeStr = (imageConfig["size"] as? String)?.split(separator: "x").first,
                  let size = Float(sizeStr) else {
                continue
            }

            let newFilename = "AppIcon_\(sizeStr)@\(scaleStr)x.png"
            let resizeConfig = ResizeConfiguration(width: Int(size * scale), height: Int(size * scale), filename: newFilename)
            resizeConfigs.append(resizeConfig)

            var mutableImageConfig = imageConfig
            mutableImageConfig["filename"] = newFilename
            filteredImageConfigs.append(mutableImageConfig)
        }

        /// If prefers universal, generate 1024x1024 images for `ios` and `watchos`.
        if prefersUniversal {
            for platform in platforms {
                guard platform == .ios || platform == .watchos else {
                    continue
                }

                let filename = "AppIcon_\(platform.rawValue).png"
                resizeConfigs.append(ResizeConfiguration(width: 1024, height: 1024, filename: filename))
                filteredImageConfigs.append([
                    "filename" : filename,
                    "idiom" : "universal",
                    "platform" : platform.rawValue,
                    "size" : "1024x1024",
                ])
            }
        }

        resizeConfigs.forEach { config in
            try? resizeImage(imageSource: imageSource, resizeConfiguration: config, outputUrl: outputFolder)
        }

        config["images"] = filteredImageConfigs
        try AssetUtils.writeDictionaryToJson(config, filename: "Contents.json", url: outputFolder)

        print("[assetool] IconSet generated at \(outputFolder)")
    }

    private func getPlatform(from config: [String: Any]) -> AssetKit.Platform? {
        if (config["idiom"] as? String) == "mac" {
            return .macos
        }
        if let platformString = config["platform"] as? String {
            if platformString == "ios" {
                return .ios
            } else if platformString == "watchos" {
                return .watchos
            }
        }
        return nil
    }

    public func generateImageSet(input: NSImage,
                                 filename: String,
                                 outputPath: String,
                                 width: CGFloat? = nil,
                                 height: CGFloat? = nil) throws {
        let imageSource = try AssetUtils.createCGImageSource(from: input)
        try generateImageSet(
            imageSource: imageSource,
            filename: filename,
            outputPath: outputPath,
            width: width,
            height: height)
    }

    public func generateImageSet(inputPath: String,
                                 outputPath: String,
                                 width: CGFloat? = nil,
                                 height: CGFloat? = nil) throws {
        let imageSource = try AssetUtils.createCGImageSource(from: inputPath)
        try generateImageSet(
            imageSource: imageSource,
            filename: AssetUtils.extractFilename(inputPath: inputPath),
            outputPath: outputPath,
            width: width,
            height: height)
    }

    private func generateImageSet(imageSource: CGImageSource,
                                  filename: String,
                                  outputPath: String,
                                  width: CGFloat? = nil,
                                  height: CGFloat? = nil) throws {
        guard let originalSize = AssetUtils.sizeOfImageSource(imageSource) else {
            throw AssetGeneratorError.resourceError
        }

        var config = try AssetUtils.loadResourceJson(filename: "image_contents")

        // @1x size
        var oneXWidth: CGFloat = 0
        var oneXHeight: CGFloat = 0

        if let width = width, let height = height {
            oneXWidth = width
            oneXHeight = height
        } else if let width = width, height == nil {
            oneXWidth = width
            oneXHeight = oneXWidth * originalSize.height / originalSize.width
        } else if let height = height, width == nil {
            oneXHeight = height
            oneXWidth = oneXHeight * originalSize.width / originalSize.height
        } else {
            oneXWidth = originalSize.width / 3
            oneXHeight = originalSize.height / 3
        }

        let outputFolder = URL(fileURLWithPath: outputPath).appendingPathComponent("\(filename).imageset")

        try AssetUtils.createDirectoryIfNeeded(url: outputFolder)

        var resizeConfigs: [ResizeConfiguration] = []

        guard var imageConfigs = config["images"] as? [[String: Any]] else {
            throw AssetGeneratorError.configError
        }
        for i in 0 ..< imageConfigs.count {
            guard let scaleStr = imageConfigs[i]["scale"] as? String,
                  let scale = Int(scaleStr.prefix(1)) else {
                throw AssetGeneratorError.configError
            }

            let newFilename = "\(filename)@\(scale)x.png"
            let resizeConfig = ResizeConfiguration(
                width: Int(oneXWidth * CGFloat(scale)),
                height: Int(oneXHeight * CGFloat(scale)),
                filename: newFilename)
            resizeConfigs.append(resizeConfig)

            imageConfigs[i]["filename"] = newFilename
        }

        resizeConfigs.forEach { config in
            try? resizeImage(imageSource: imageSource, resizeConfiguration: config, outputUrl: outputFolder)
        }

        config["images"] = imageConfigs
        try AssetUtils.writeDictionaryToJson(config, filename: "Contents.json", url: outputFolder)
    }

    private func resizeImage(imageSource: CGImageSource,
                             resizeConfiguration: ResizeConfiguration,
                             outputUrl: URL) throws {
        let options = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(resizeConfiguration.width, resizeConfiguration.height),
        ] as [CFString : Any] as CFDictionary

        guard let resized = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) else {
            throw AssetGeneratorError.dataSourceError
        }
        let imageRep = NSBitmapImageRep(cgImage: resized)
        imageRep.size = NSSize(width: resizeConfiguration.width, height: resizeConfiguration.height)
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else {
            throw AssetGeneratorError.resizeError
        }

        let fileUrl = outputUrl.appendingPathComponent(resizeConfiguration.filename)
        return try pngData.write(to: fileUrl)
    }

}
