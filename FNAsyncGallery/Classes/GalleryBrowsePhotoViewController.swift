//
//  GalleryBrowsePhotoViewController.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 12/5/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

@objc protocol GalleryBrowserDataSource {
    func imageEntityForPage(page: Int, inGalleyBrowser galleryBrowser: GalleryBrowsePhotoViewController) -> FNImage?
    func numberOfImagesForGalleryBrowser(browser: GalleryBrowsePhotoViewController) -> Int
}

class GalleryBrowsePhotoViewController: UIViewController, UIScrollViewDelegate {
    
    var dataSource: GalleryBrowserDataSource?
    var scrollView: UIScrollView!
    
    var currentPage: Int {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        return page
    }
    
    var currentImageEntity: FNImage? {
        return dataSource?.imageEntityForPage(currentPage, inGalleyBrowser: self)
    }
    
    private var layedOutScrollView = false
    
    var startPage: Int = 0
    private var imageCount: Int = 0
    private var pageViews = [GalleryBrowserPageView?]()
    
    init(startPage: Int) {
        super.init()
        self.startPage = startPage
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        commonSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !layedOutScrollView {
            // Size scroll view contents
            if dataSource == nil {
                fatalError("Unable to load browser: data source is nil.")
            }
            
            imageCount = dataSource!.numberOfImagesForGalleryBrowser(self)
            navigationItem.title = "\(startPage + 1) / \(imageCount)"

            for _ in 0..<imageCount {
                pageViews.append(nil)
            }
            scrollView.contentSize = CGSize(width: CGFloat(imageCount) * scrollView.bounds.width, height: scrollView.bounds.height)
            layedOutScrollView = true
            
            println("scrollview content size \(scrollView.contentSize) real \(scrollView.frame)")
            
            // Modify start page
            scrollView.contentOffset = CGPoint(x: CGFloat(startPage) * scrollView.bounds.width, y: 0)
            loadVisiblePages()
        }
    }
    
    private func commonSetup() {
        automaticallyAdjustsScrollViewInsets = false
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonTapped:")
        let attributeDict = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.titleTextAttributes = attributeDict
        scrollView = UIScrollView()
        scrollView.scrollEnabled = true
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .White
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.delegate = self
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        layout(scrollView) { v in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom
        }
        
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // This solution comes from "How To Use UIScrollView to Scroll and Zoom Content in Swift" written by Michael Briscoe on RayWenderlich
    func loadPage(page: Int) {
        if page < 0 || page >= imageCount {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let imageEntity = dataSource!.imageEntityForPage(page, inGalleyBrowser: self)!
            imageEntity.page = page
            if imageEntity.sourceImageState == .NotLoaded {
                imageEntity.loadSourceImageWithCompletion({ (error) -> Void in
                    if let pageView = self.pageViews[imageEntity.page!] {
                        if error == nil {
                            println("reload page \(page) image complete")
                            pageView.image = imageEntity.sourceImage
                        } else {
                            println("reload page \(page) error \(error)")
                        }
                    }
                })
            }
            
            let newPageView = GalleryBrowserPageView(frame: frame)
            newPageView.image = imageEntity.sourceImage ?? imageEntity.thumbnail
            imageEntity.delegate = newPageView
            newPageView.setActivityAccordingToImageState(imageEntity.sourceImageState)
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= imageCount {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    func loadVisiblePages() {
        // Work out which pages you want to load
        let firstPage = currentPage - 1
        let lastPage = currentPage + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < imageCount; ++index {
            purgePage(index)
        }
    }

    // MARK: Scroll View Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadVisiblePages()
        navigationItem.title = "\(currentPage + 1) / \(imageCount)"
    }
    
}

class GalleryBrowserPageView: UIView, FNImageDelegate {

    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var imageView = UIImageView()
    lazy private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        layout(imageView) { v in
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
    
    // MARK: FNImage Delegate
    func sourceImageStateChangedForImageEntity(imageEntity: FNImage, oldState: FNImage.FNImageSourceImageState, newState: FNImage.FNImageSourceImageState) {
        setActivityAccordingToImageState(newState)
    }
}
