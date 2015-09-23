//
//  ImageCacheManager.swift
//  AsyncPhotoBrowser
//
//  Created by Sihao Lu on 11/30/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit
import Alamofire
import FastImageCache

/// A manager to manage the FastImageCache used on Gallery View Controller.
/// You may create a subclass of it to use support other images you wish to cache using FastImageCache.

class ImageCacheManager: NSObject, FICImageCacheDelegate {
    
    /// Get the shared image cache manager object
    /// - returns: A singleton object for the shared image cache manager
    class var sharedManager : ImageCacheManager {
        struct Static {
            static let instance : ImageCacheManager = ImageCacheManager()
        }
        return Static.instance
    }
    
    func setupFastImageCacheWithImageSize(size: CGSize) {
        if FICImageCache.sharedImageCache().formatsWithFamily(FNImageImageFormatFamily) != nil {
            return
        }
        FICImageCache.sharedImageCache().delegate = self
        let squareImageFormatDevices: FICImageFormatDevices = [.Phone, .Pad]
        let imageFormat = FICImageFormat(name: FNImageSquareImage32BitBGRAFormatName, family: FNImageImageFormatFamily, imageSize: size, style: FICImageFormatStyle.Style32BitBGRA, maximumCount: 1000, devices: squareImageFormatDevices, protectionMode: .None)
        FICImageCache.sharedImageCache().setFormats([imageFormat])
    }
    
    // MARK: FICImageCache Delegate
    func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: FICEntity!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
        if let imageEntity = entity as? FNImage {
            imageEntity.sourceImageState = .Loading
            
            guard imageEntity.URL.scheme != "file" else {
                imageEntity.sourceImage = UIImage(contentsOfFile: imageEntity.URL.path!)
                imageEntity.sourceImageState = .Ready
                completionBlock(UIImage(contentsOfFile: imageEntity.URL.path!)!)
                return
            }
            
            request(.GET, imageEntity.URL).response { (_, response, data, error) in
                if error != nil {
                    print(error)
                    imageEntity.sourceImageState = .Failed
                    completionBlock(nil)
                    return
                }
                if let imageData = data {
                    if let sourceImage = UIImage(data: imageData) {
                        imageEntity.sourceImage = sourceImage
                        imageEntity.sourceImageState = .Ready
                        completionBlock(sourceImage)
                        return
                    }
                }
                imageEntity.sourceImageState = .Failed
                completionBlock(nil)
            }
        }
    }
    
    func imageCache(imageCache: FICImageCache!, shouldProcessAllFormatsInFamily formatFamily: String!, forEntity entity: FICEntity!) -> Bool {
        if entity is FNImage {
            return false
        }
        return true
    }
    
    func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
        print("\(errorMessage)")
    }
    
}
