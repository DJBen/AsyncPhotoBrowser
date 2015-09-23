//
//  GalleryViewControllerTransitioning.swift
//  AsyncPhotoBrowser
//
//  Created by Sihao Lu on 12/21/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class GalleryViewControllerAnimator: NSObject, UIViewControllerTransitioningDelegate {
    
    var selectedImage: UIImage?
    var cellFrame: CGRect
    
    init(selectedImage: UIImage?, fromCellWithFrame cellFrame: CGRect) {
        self.selectedImage = selectedImage
        self.cellFrame = cellFrame
    }
    
    // MARK: Transitioning Delegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return defaultTransitioning()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = defaultTransitioning()
        let galleryTransitioning = transitioning as! GalleryViewControllerTransitioning
        let browser = ((dismissed as! UINavigationController).viewControllers[0]) as! GalleryBrowsePhotoViewController
        galleryTransitioning.image = browser.currentImageEntity?.sourceImage ?? browser.currentImageEntity?.thumbnail
        galleryTransitioning.reversed = true
        galleryTransitioning.zoomToCellFrameUponDismissal = browser.startPage == browser.currentPage
        return galleryTransitioning
    }
    
    private func defaultTransitioning() -> UIViewControllerAnimatedTransitioning {
        let transitioning = GalleryViewControllerTransitioning()
        transitioning.cellFrame = cellFrame
        transitioning.image = selectedImage
        return transitioning
    }
}

class GalleryViewControllerTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var reversed: Bool = false
    var image: UIImage?
    var cellFrame = CGRect()
    var zoomToCellFrameUponDismissal = true
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let container = transitionContext.containerView()!
        let transitionDuration = self.transitionDuration(transitionContext)
        
        if !reversed {
            container.addSubview(toView)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .ScaleAspectFit
            imageView.frame = cellFrame
            container.addSubview(imageView)
            toView.alpha = 0
            UIView.animateWithDuration(transitionDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                fromView.alpha = 0
                imageView.frame = UIScreen.mainScreen().bounds
            }, completion: { complete in
                fromView.alpha = 1
                toView.alpha = 1
                imageView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        } else {
            container.addSubview(toView)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .ScaleAspectFit
            imageView.frame = UIScreen.mainScreen().bounds
            container.addSubview(imageView)
            UIView.animateWithDuration(transitionDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                fromView.alpha = 0
                imageView.alpha = 0
                if self.zoomToCellFrameUponDismissal {
                    imageView.frame = self.cellFrame
                } else {
                    imageView.transform = CGAffineTransformMakeScale(1.5, 1.5)
                }
            }, completion: { complete in
                imageView.removeFromSuperview()
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
}
