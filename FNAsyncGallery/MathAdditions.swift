//
//  MathAdditions.swift
//  FNAsyncGallery
//
//  Created by Sihao Lu on 12/23/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return left + (-right)
}

func +(left: CGRect, right: CGPoint) -> CGRect {
    return CGRect(origin: left.origin + right, size: left.size)
}

func -(left: CGRect, right: CGPoint) -> CGRect {
    return left + (-right)
}

prefix func -(point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}