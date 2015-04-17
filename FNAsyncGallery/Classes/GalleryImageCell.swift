//
//  GalleryImageCell.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 11/30/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit
import Cartography

class GalleryImageCell: UICollectionViewCell {
    let imageView = UIImageView(frame: CGRectZero)
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
//    var imageEntity: FICEntity? 
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 0.8, alpha: 1)
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout(imageView) { v in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom
        }
    }
}
