FNAsyncGallery
==============

High performance gallery designed for web images built with FastImageCache.

## Usage
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
        
        func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> String {
            // return the URL of image at index path
        }
        
## Screenshots
![FastImageCache Demo](https://github.com/DJBen/FNAsyncGallery/blob/master/Screenshots/Screen%20Shot%202014-12-23%20at%202.10.45%20AM.png "FastImageCache")

![Photo Browser](https://github.com/DJBen/FNAsyncGallery/blob/master/Screenshots/Screen%20Shot%202014-12-23%20at%202.10.51%20AM.png "Photo Browser")

## TODO
1. Gallery View Controller currently has only one section containing all images.
2. Transition from collection view controller to browse-specific-photo view controller is broken. I turned it off.
3. Photo zooming unimplemented.

## Notes
This is an experiment of `FastImageCache`.

Photo gallery serves an important role among many use cases. Sadly there is not a perfect solution that is both automatic and has high performance at the same time. My purpose is to implement such a solution as perfect as possible. I appreciate any help from you if you are interested! 
## License
MIT
