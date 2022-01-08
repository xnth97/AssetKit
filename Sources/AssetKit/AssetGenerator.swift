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
        case resizeError
    }

    public struct ResizeConfiguration {
        let width: Int
        let height: Int
        let filename: String
    }

    private static let platformIdiomMap: [AssetKit.Platform: Set<String>] = [
        .iphone: Set(["iphone", "ios-marketing"]),
        .ipad: Set(["ipad", "ios-marketing"]),
        .ios: Set(["iphone", "ipad", "ios-marketing"]),
        .watch: Set(["watch", "watch-marketing"]),
        .car: Set(["car", "car"]),
        .mac: Set(["mac"]),
    ]

    public func generateIconSet(inputPath: String,
                                outputPath: String,
                                platforms: [AssetKit.Platform] = [.ios]) throws {
        guard let imageSource = AssetUtils.createCGImageSource(from: inputPath),
              var config = AssetUtils.loadResourceJson(filename: "icon_contents") else {
                  throw AssetGeneratorError.dataSourceError
              }

        let outputFolder = URL(fileURLWithPath: outputPath).appendingPathComponent("AppIcon.appiconset")
        try AssetUtils.createDirectoryIfNeeded(url: outputFolder)

        var resizeConfigs: [ResizeConfiguration] = []
        var filteredImageConfigs: [[String: Any]] = []
        guard let imageConfigs = config["images"] as? [[String: Any]] else {
            throw AssetGeneratorError.configError
        }
        for imageConfig in imageConfigs {
            guard let idiom = imageConfig["idiom"] as? String else {
                throw AssetGeneratorError.configError
            }

            func shouldUseThisConfig() -> Bool {
                for platform in platforms {
                    guard let platformIdiomStringSet = Self.platformIdiomMap[platform] else {
                        continue
                    }
                    if platformIdiomStringSet.contains(idiom) {
                        return true
                    }
                }
                return false
            }

            guard shouldUseThisConfig() else {
                continue
            }

            guard let scaleStr = (imageConfig["scale"] as? String)?.prefix(1),
                  let scale = Float(scaleStr),
                  let sizeStr = (imageConfig["size"] as? String)?.split(separator: "x")[0],
                  let size = Float(sizeStr) else {
                      continue
                  }

            let newFilename = "AppIcon-\(sizeStr)@\(scaleStr)x.png"
            let resizeConfig = ResizeConfiguration(width: Int(size * scale), height: Int(size * scale), filename: newFilename)
            resizeConfigs.append(resizeConfig)

            var mutableImageConfig = imageConfig
            mutableImageConfig["filename"] = newFilename
            filteredImageConfigs.append(mutableImageConfig)
        }

        resizeConfigs.forEach { config in
            try? resizeImage(imageSource: imageSource, resizeConfiguration: config, outputUrl: outputFolder)
        }

        config["images"] = filteredImageConfigs
        try AssetUtils.writeDictionaryToJson(config, filename: "Contents.json", url: outputFolder)
    }

    public func generateImageSet(inputPath: String,
                                 outputPath: String,
                                 width: CGFloat? = nil,
                                 height: CGFloat? = nil) throws {
        guard let imageSource = AssetUtils.createCGImageSource(from: inputPath),
              let originalSize = AssetUtils.sizeOfImage(at: inputPath),
              var config = AssetUtils.loadResourceJson(filename: "image_contents") else {
                  throw AssetGeneratorError.dataSourceError
              }

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

        let filename = AssetUtils.extractFilename(inputPath: inputPath)
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
        ] as CFDictionary

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
