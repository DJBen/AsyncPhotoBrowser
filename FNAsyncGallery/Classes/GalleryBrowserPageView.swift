//
//  GalleryBrowserPageView.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 12/24/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit
import Cartography

class GalleryBrowserPageView: UIView, FNImageDelegate, UIScrollViewDelegate {
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set(newImage) {
            imageView.image = newImage
            imageView.frame = CGRect(origin: CGPointZero, size: newImage?.size ?? CGSizeZero)
            
            // Adjust scroll view zooming
            scrollView.contentSize = newImage?.size ?? self.bounds.size
            let scrollViewFrame = scrollView.frame
            let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight)
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 1.0
            scrollView.zoomScale = minScale
            
            self.centerScrollViewContents()
        }
    }
    
    weak var imageEntity: FNImage!
    
    lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.bounds)
        scrollView.contentSize = self.bounds.size
        scrollView.bouncesZoom = true
        scrollView.delegate = self
        
        // Set up gesture recognizer
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        return scrollView
    }()
    
    lazy var imageView: UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.contentMode = .ScaleAspectFit
        tempImageView.opaque = true
        return tempImageView
    }()
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        let tempActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        tempActivityIndicatorView.hidesWhenStopped = true
        return tempActivityIndicatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        addSubview(activityIndicator)
        layout(scrollView) { v in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom
        }
        layout(activityIndicator) { v in
            v.centerX == v.superview!.centerX
            v.centerY == v.superview!.centerY
        }
    }
    
    func setActivityAccordingToImageState(state: FNImage.FNImageSourceImageState) {
        switch state {
        case .Paused:
            fallthrough
        case .Loading:
            activityIndicator.startAnimating()
        case .Ready:
            fallthrough
        case .Failed:
            fallthrough
        case .NotLoaded:
            activityIndicator.stopAnimating()
        }
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        imageView.frame = contentsFrame
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imageView)
        
        // 2
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }

    
    // MARK: Scroll View Delegate
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if imageEntity.sourceImageState == .Ready {
            return imageView
        }
        return nil
    }
    
    // MARK: FNImage Delegate
    func sourceImageStateChangedForImageEntity(imageEntity: FNImage, oldState: FNImage.FNImageSourceImageState, newState: FNImage.FNImageSourceImageState) {
        setActivityAccordingToImageState(newState)
    }
    
}

