//
//  GalleryViewController.swift
//  AsyncPhotoBrowser
//
//  Created by Sihao Lu on 11/18/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit
import Cartography
import FastImageCache

/// The gallery data source protocol. Implement this protocol to supply custom data to the gallery.
@objc public protocol GalleryDataSource {
    /**
        The number of sections in the gallery.
        Currently has no effect.
        
        - parameter gallery: The gallery being displayed.
    
        - returns: The number of sections in the gallery.
    */
    optional func numberOfSectionsInGallery(gallery: GalleryViewController) -> Int
    
    /**
        The number of images in current section.
    
        - parameter gallery: The gallery being displayed.
        - parameter section: The section of the images being displayed.
    
        - returns: The number of images in current section.
    */
    func gallery(gallery: GalleryViewController, numberOfImagesInSection section: Int) -> Int
    
    /**
        The number of images in current section.
    
        - parameter gallery: The gallery being displayed.
        - parameter indexPath: The indexPath of the image being displayed.
    
        - returns: The image URL of the current image.
    */
    func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> NSURL
}

public class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GalleryBrowserDataSource {
    
    public enum GalleryCellSizingMode {
        case FixedSize(CGSize)
        case FixedItemsPerRow(Int)
    }
    
    let collectionViewCellIdentifier = "imageCell"
    var collectionView: UICollectionView!
    public var dataSource: GalleryDataSource?
    
    /** 
        The cell sizing mode: Fixed number of items per row or fixed size.
    
        :discussion: Set this before laying out the GalleryViewController. Any setter call after that does nothing, because the FastImageCache only initializes once.
    */
    public var cellSizingMode: GalleryCellSizingMode = .FixedItemsPerRow(3) {
        didSet {
            if cacheAlreadySetup {
                self.cellSizingMode = oldValue
            } else {
                collectionView?.reloadData()
            }
        }
    }
    
    /**
        The minimum spacing between items. Has effect when cellSizingMode is set to .FixedItemsPerRow.
    */
    public var itemSpacing: CGFloat = 4
    
    private var cacheAlreadySetup: Bool = false
    private var collectionViewLayout = UICollectionViewFlowLayout()
    private var images = [NSIndexPath: FNImage]()
    private var selectedIndexPath: NSIndexPath?
    private var animator: UIViewControllerTransitioningDelegate!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(GalleryImageCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier)
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(collectionView)
        
        constrain(collectionView) { c in
            c.left == c.superview!.left
            c.right == c.superview!.right
            c.top == c.superview!.top
            c.bottom == c.superview!.bottom
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !cacheAlreadySetup {
            var itemSize: CGSize!
            switch cellSizingMode {
            case .FixedSize(let size):
                itemSize = size
            case .FixedItemsPerRow(_):
                itemSize = collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
            }
            ImageCacheManager.sharedManager.setupFastImageCacheWithImageSize(itemSize)
            cacheAlreadySetup = true
            collectionView.reloadData()
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    private func indexPathForPage(page: Int) -> NSIndexPath? {
        if page < 0 {
            return nil
        }
        var targetPage = page
        for section in 0..<self.numberOfSectionsInCollectionView(collectionView) {
            let itemsInCurrentSection = self.collectionView(collectionView, numberOfItemsInSection: section)
            if targetPage < itemsInCurrentSection {
                return NSIndexPath(forItem: targetPage, inSection: section)
            }
            targetPage -= itemsInCurrentSection
        }
        return nil
    }
    
    // MARK: Collection View Data Source
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSectionsInGallery?(self) ?? 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.gallery(self, numberOfImagesInSection: section) ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewCellIdentifier, forIndexPath: indexPath) as! GalleryImageCell
        
        // If the cache is properly set up, try to retrieve the image from internet
        if FICImageCache.sharedImageCache().formatWithName(FNImageSquareImage32BitBGRAFormatName) != nil {
            let imageURL: NSURL? = dataSource?.gallery(self, imageURLAtIndexPath: indexPath)
            if imageURL != nil {
                var imageEntity: FNImage!
                imageEntity = images[indexPath]
                if imageEntity == nil {
                    imageEntity = FNImage(URL: imageURL!, indexPath: indexPath)
                    images[indexPath] = imageEntity
                }
                let imageExists = FICImageCache.sharedImageCache().imageExistsForEntity(imageEntity, withFormatName: FNImageSquareImage32BitBGRAFormatName)
                FICImageCache.sharedImageCache().retrieveImageForEntity(imageEntity, withFormatName: FNImageSquareImage32BitBGRAFormatName) { (entity, formatName, image) -> Void in
                    let theImageEntity = entity as! FNImage
                    theImageEntity.thumbnail = image
                    
                    // Trigger partial update only if new image comes in
                    if !imageExists {
                        if image != nil {
                            self.collectionView.reloadItemsAtIndexPaths([theImageEntity.indexPath!])
                        } else {
                            print("Failed to retrieve image at (\(indexPath.section), \(indexPath.row))")
                        }
                    }
                }
            }
        }
        cell.image = self.images[indexPath]?.thumbnail
        return cell
    }
    
    // MARK: Collection View Delegate
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return itemSpacing
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return itemSpacing
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch cellSizingMode {
        case .FixedSize(let size):
            return size
        case .FixedItemsPerRow(let itemsPerRow):
            let minItemSpacing: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: indexPath.section)
            let optimumWidth = (collectionView.bounds.size.width - minItemSpacing * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)
            return CGSize(width: optimumWidth, height: optimumWidth)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageEntity = self.images[indexPath]!
        if imageEntity.isReady {
            var page: Int = 0
            for section in 0..<indexPath.section {
                page += self.collectionView(collectionView, numberOfItemsInSection: section)
            }
            page += indexPath.row
            selectedIndexPath = indexPath
            modalPresentationStyle = .FullScreen
            let browser = GalleryBrowsePhotoViewController(startPage: page)
            browser.dataSource = self
            let navigationController = UINavigationController(rootViewController: browser)
            
            // Figure out selected image: choose source image whenever possible
            let selectedImage = images[selectedIndexPath!]!.sourceImage ?? images[selectedIndexPath!]!.thumbnail
            
            // Calculate the frame of image user touches
            let offsetAdjustment: CGPoint = collectionView.contentOffset
            let cellFrame = self.collectionView.layoutAttributesForItemAtIndexPath(selectedIndexPath!)!.frame - offsetAdjustment
            animator = GalleryViewControllerAnimator(selectedImage: selectedImage, fromCellWithFrame: cellFrame)
            
            // Set transition animator
            navigationController.transitioningDelegate = animator
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: Gallery Browser Delegate
    func numberOfImagesForGalleryBrowser(browser: GalleryBrowsePhotoViewController) -> Int {
        var imageCount: Int = 0
        for section in 0..<self.numberOfSectionsInCollectionView(collectionView) {
            imageCount += self.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return imageCount
    }
    
    func imageEntityForPage(page: Int, inGalleyBrowser galleryBrowser: GalleryBrowsePhotoViewController) -> FNImage? {
        let indexPath = self.indexPathForPage(page)
        return self.images[indexPath!]
    }
    
}

