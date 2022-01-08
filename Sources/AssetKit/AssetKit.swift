//
//  AssetKit.swift
//  AssetKit
//
//  Created by Yubo Qin on 1/6/22.
//

import Foundation

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

    public static func generateImageSet(inputPath: String,
                                        outputPath: String,
                                        width: CGFloat? = nil,
                                        height: CGFloat? = nil) {
        try? generator.generateImageSet(inputPath: inputPath, outputPath: outputPath, width: width, height: height)
    }

    public static func generateIconSet(inputPath: String,
                                       outputPath: String,
                                       platforms: [Platform] = [.ios]) {
        try? generator.generateIconSet(inputPath: inputPath, outputPath: outputPath, platforms: platforms)
    }

}
