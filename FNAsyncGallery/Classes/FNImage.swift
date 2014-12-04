//
//  FNImage.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 11/30/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

let FNImageImageFormatFamily = "FICDPhotoImageFormatFamily"
let FNImageSquareImage32BitBGRAFormatName = "edu.jhu.djben.FNAsyncGallery.FICDPhotoSquareImage32BitBGRAFormatName"

class FNImage: NSObject, FICEntity {
    private var _UUID: String!
    var URLString: String
    var indexPath: NSIndexPath?
    var sourceImage: UIImage?
    
    var UUID: String {
        get {
            if _UUID == nil {
                let UUIDBytes = FICUUIDBytesFromMD5HashOfString(self.URLString)
                _UUID = FICStringWithUUIDBytes(UUIDBytes)
            }
            return _UUID
        }
    }
    
    var sourceImageUUID: String {
        get {
            return self.UUID
        }
    }
    
    init(URLString: String, indexPath: NSIndexPath? = nil) {
        self.URLString = URLString
        self.indexPath = indexPath
        super.init()
    }
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return NSURL(string: URLString)
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        let drawingBlock: FICEntityImageDrawingBlock = { context, contextSize in
            let contextBounds = CGRect(origin: CGPointZero, size: contextSize)
            CGContextClearRect(context, contextBounds)
            if formatName != FNImageSquareImage32BitBGRAFormatName {
                // Fill with white for image formats that are opaque
                CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                CGContextFillRect(context, contextBounds)
            }
            let squareImage = image.squareImage()
            
            UIGraphicsPushContext(context)
            squareImage.drawInRect(contextBounds)
            UIGraphicsPopContext()
        }
        return drawingBlock
    }
}

extension UIImage {
    
    /** 
        Generate a square thumbnail of current image.
    
        See https://github.com/path/FastImageCache/blob/master/FastImageCacheDemo/Classes/FICDPhoto.m for the original version.
    
        :returns: a square version of the current image.
    */
    func squareImage() -> UIImage {
        var squareImage: UIImage!
        let imageSize = self.size
    
        if (imageSize.width == imageSize.height) {
            squareImage = self
        } else {
            // Compute square crop rect
            let smallerDimension: CGFloat = min(imageSize.width, imageSize.height)
            var cropRect = CGRectMake(0, 0, smallerDimension, smallerDimension)
    
            // Center the crop rect either vertically or horizontally, depending on which dimension is smaller
            if (imageSize.width <= imageSize.height) {
                cropRect.origin = CGPoint(x: 0, y: rint((imageSize.height - smallerDimension) / 2.0))
            } else {
                cropRect.origin = CGPoint(x: rint((imageSize.width - smallerDimension) / 2.0), y: 0)
            }
            let croppedImageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect)
            squareImage = UIImage(CGImage:croppedImageRef)
        }
        return squareImage;
    }
}