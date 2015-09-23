//
//  GalleryExampleViewController.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 11/20/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class GalleryExampleViewController: GalleryViewController, GalleryDataSource {
    
    var imageURLs: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        imageURLs = ["http://img1.3lian.com/img2011/w1/103/41/d/50.jpg", "http://www.old-radio.info/wp-content/uploads/2014/09/cute-cat.jpg", "http://static.tumblr.com/aeac4c29583da7972652d382d8797876/sz5wgey/Tejmpabap/tumblr_static_cats-1.jpg", "http://resources2.news.com.au/images/2013/11/28/1226770/056906-cat.jpg"]
        for i in 0...99 {
            let formattedIndex = String(format: "%03d", i)
            imageURLs.append("https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage\(formattedIndex).jpg")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "AsyncPhotoBrowser"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gallery(gallery: GalleryViewController, numberOfImagesInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> NSURL {
        return NSURL(string: imageURLs[indexPath.row])!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
