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

func ==(left: FNImage, right: FNImage) -> Bool {
    return left.URLString == right.URLString
}

protocol FNImageDelegate {
    func sourceImageStateChangedForImageEntity(imageEntity: FNImage, oldState: FNImage.FNImageSourceImageState, newState: FNImage.FNImageSourceImageState)
}

class FNImage: NSObject, FICEntity, Hashable {
    
    enum FNImageSourceImageState {
        case NotLoaded
        case Loading
        case Ready
        case Failed
    }
    
    private var _UUID: String!
    var URLString: String
    var indexPath: NSIndexPath?
    var page: Int?
    var sourceImage: UIImage?
    var thumbnail: UIImage?
    var delegate: FNImageDelegate?
    
    private var reloadRequest: Request?
    
    override var hashValue: Int {
        return self.URLString.hashValue
    }
    
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
    
    var isReady: Bool {
        return thumbnail != nil && indexPath != nil
    }
    
    var sourceImageState: FNImageSourceImageState = .NotLoaded {
        willSet {
            self.delegate?.sourceImageStateChangedForImageEntity(self, oldState: self.sourceImageState, newState: newValue)
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
    
    func loadSourceImageWithCompletion(completion: ((error: NSError?) -> Void)?) {
        if reloadRequest != nil {
            return
        }
        sourceImageState = .Loading
        reloadRequest = request(.GET, self.URLString).response { (_, _, data, error) in
            self.reloadRequest = nil
            if error != nil {
                completion?(error: error)
                self.sourceImageState = .Failed
                return
            }
            if let imageData = data as? NSData {
                if let image = UIImage(data: imageData) {
                    self.sourceImage = image
                    self.sourceImageState = .Ready
                    completion?(error: nil)
                    return
                }
            }
            self.sourceImageState = .Failed
            completion?(error: NSError(domain: "FNImageErrorDomain", code: 0, userInfo: nil))
        }
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