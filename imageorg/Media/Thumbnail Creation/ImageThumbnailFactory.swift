//
//  ImageThumbnailFactory.swift
//  imageorg
//
//  Created by Finn Schlenk on 06.01.19.
//  Copyright © 2019 Finn Schlenk. All rights reserved.
//

import Cocoa

class ImageThumbnailFactory: ThumbnailFactory {
    static var size = NSSize(width: 460, height: 360)
    static var quality: Float = 0.7

    var localFileManager = LocalFileManager()
    var thumbnailCoreDataService = ThumbnailCoreDataService()

    func createThumbnailImage(from filePath: String, completionHandler handler: @escaping (Result<NSImage, ThumbnailError>) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = NSImage(byReferencingFile: filePath), image.isValid,
                let thumbnailImage = image.resized(to: ImageThumbnailFactory.size) else {
                handler(.failure(.notCreated))
                return
            }

            handler(.success(thumbnailImage))
        }
    }
}
