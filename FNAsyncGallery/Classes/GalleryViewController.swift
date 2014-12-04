//
//  GalleryViewController.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 11/18/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

/// The gallery data source protocol. Implement this protocol to supply custom data to the gallery.
@objc protocol GalleryDataSource {
    /**
        The number of sections in the gallery.
        Currently has no effect.
        
        :param: gallery The gallery being displayed.
    
        :returns: The number of sections in the gallery.
    */
    optional func numberOfSectionsInGallery(gallery: GalleryViewController) -> Int
    
    /**
        The number of images in current section.
    
        :param: gallery The gallery being displayed.
        :param: section The section of the images being displayed.
    
        :returns: The number of images in current section.
    */
    func gallery(gallery: GalleryViewController, numberOfImagesInSection section: Int) -> Int
    
    /**
        The number of images in current section.
    
        :param: gallery The gallery being displayed.
        :param: indexPath The indexPath of the image being displayed.
    
        :returns: The image URL of the current image.
    */
    optional func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> String
}

@objc protocol GalleryDelegate {

}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    enum GalleryCellSizingMode {
        case FixedSize(CGSize)
        case FixedItemsPerRow(Int)
    }
    
    let collectionViewCellIdentifier = "imageCell"
    var collectionView: UICollectionView!
    var dataSource: GalleryDataSource?
    
    /** 
        The cell sizing mode: Fixed number of items per row or fixed size.
    
        :discussion: Set this before laying out the GalleryViewController. Any setter call after that does nothing, because the FastImageCache only initializes once.
    */
    var cellSizingMode: GalleryCellSizingMode = .FixedItemsPerRow(3) {
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
    var itemSpacing: CGFloat = 4
    
    private var cacheAlreadySetup: Bool = false
    private var collectionViewLayout = UICollectionViewFlowLayout()
    private var photos = [NSIndexPath: UIImage]()
    
    override func viewDidLoad() {
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
        
        layout(collectionView) { c in
            c.left == c.superview!.left
            c.right == c.superview!.right
            c.top == c.superview!.top
            c.bottom == c.superview!.bottom
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
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
    
    // MARK: Collection View Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSectionsInGallery?(self) ?? 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.gallery(self, numberOfImagesInSection: section) ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewCellIdentifier, forIndexPath: indexPath) as GalleryImageCell
        // If the cache is properly set up, try to retrieve the image from internet
        if FICImageCache.sharedImageCache().formatWithName(FNImageSquareImage32BitBGRAFormatName) != nil {
            let imageURLString: String? = dataSource?.gallery?(self, imageURLAtIndexPath: indexPath)
            if imageURLString != nil {
                let image = FNImage(URLString: imageURLString!, indexPath: indexPath)
                let imageExists = FICImageCache.sharedImageCache().imageExistsForEntity(image, withFormatName: FNImageSquareImage32BitBGRAFormatName)
                FICImageCache.sharedImageCache().retrieveImageForEntity(image, withFormatName: FNImageSquareImage32BitBGRAFormatName) { (entity, formatName, image) -> Void in
                    let imageEntity = entity as FNImage
                    self.photos[imageEntity.indexPath!] = image
                    // Trigger partial update if new image comes in
                    if !imageExists {
                        self.collectionView.reloadItemsAtIndexPaths([imageEntity.indexPath!])
                    }
                }
            }
        }
        cell.image = self.photos[indexPath]
        return cell
    }
    
    // MARK: Collection View Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch cellSizingMode {
        case .FixedSize(let size):
            return size
        case .FixedItemsPerRow(let itemsPerRow):
            let minItemSpacing: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: indexPath.section)
            let optimumWidth = (collectionView.bounds.size.width - minItemSpacing * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)
            return CGSize(width: optimumWidth, height: optimumWidth)
        }
    }
    
}

