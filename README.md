AsyncPhotoBrowser
==============

High performance gallery designed for web images built with FastImageCache. It consists of a grid view controller that contains all thumbnails of the images. You can tap on any of the photos to browse specific images in a browser view controller with zoom in / out and scrolling capabilities.

## Usage

### Installation via Cocoapods
This is the recommended approach.

    pod 'AsyncPhotoBrowser', '~> 0.2.0'
        
### How to start
1. Import all files in `/Classes`.
2. Create a subclass of `GalleryViewController`.
3. Implement `GalleryDataSource` protocol. As examples shown below

        override func awakeFromNib() {
            super.awakeFromNib()
            // Set dataSource of GalleryViewController
            self.dataSource = self
            ...
        }
    
        // MARK: Gallery Data Source
        func gallery(gallery: GalleryViewController, numberOfImagesInSection section: Int) -> Int {
            // return number of images
        }
        
        func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> NSURL {
            // return the remote or local URL of the specific image
        }
        
## Demo
![FastImageCache Demo](https://raw.githubusercontent.com/DJBen/FNAsyncGallery/master/Screenshots/FNAsyncGallery_Demo.gif "FastImageCache")

## Pending Improvements
1. Gallery View Controller currently has only one section containing all images. Consider adding more sections.

## Known Issues
1. ~~Scrolling gesture on the transparent part of images doesn't work.~~
2. Zooming sometimes makes image scrolling stuck. Zooming it again can solve this problem.

## Notes
This is an experiment of `FastImageCache`.

Photo gallery serves an important role among many use cases. Sadly there is not a perfect solution that is both automatic and has high performance at the same time. My purpose is to implement such a solution as perfect as possible. I appreciate any help from you if you are interested! 

## License
MIT
