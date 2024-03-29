//
//  AssetUtils.swift
//  AssetKit
//
//  Created by Yubo Qin on 1/7/22.
//

import Foundation
import AppKit
import ImageIO

struct AssetUtils {

    static func loadResourceJson(filename: String) throws -> [String: Any] {
        guard let jsonUrl = Bundle.module.url(forResource: filename, withExtension: "json"),
              let jsonData = try? Data(contentsOf: jsonUrl),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw AssetGenerator.AssetGeneratorError.configError
        }
        return jsonDict
    }

    static func createCGImageSource(from path: String) throws -> CGImageSource {
        let fileUrl = URL(fileURLWithPath: path) as CFURL
        guard let imageSource = CGImageSourceCreateWithURL(fileUrl, nil) else {
            throw AssetGenerator.AssetGeneratorError.dataSourceError
        }
        return imageSource
    }

    static func createCGImageSource(from image: NSImage) throws -> CGImageSource {
        guard let data = image.tiffRepresentation,
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw AssetGenerator.AssetGeneratorError.dataSourceError
        }
        return imageSource
    }

    static func sizeOfImage(for image: NSImage) -> CGSize? {
        guard let source = try? createCGImageSource(from: image) else {
            return nil
        }
        return sizeOfImageSource(source)
    }

    static func sizeOfImage(at path: String) -> CGSize? {
        guard let source = try? createCGImageSource(from: path) else {
            return nil
        }
        return sizeOfImageSource(source)
    }

    static func sizeOfImageSource(_ source: CGImageSource) -> CGSize? {
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }

        guard let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat else {
            return nil
        }

        return CGSize(width: width, height: height)
    }

    static func writeDictionaryToJson(_ dict: [String: Any], filename: String, url: URL) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let outputUrl = url.appendingPathComponent(filename)
        try jsonData.write(to: outputUrl)
    }

    static func extractFilename(inputPath: String) -> String {
        return (URL(fileURLWithPath: inputPath).lastPathComponent as NSString).deletingPathExtension
    }

    static func createDirectoryIfNeeded(url: URL) throws {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &isDirectory) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

}
