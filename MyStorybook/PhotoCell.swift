//
//  PhotoCell.swift
//  MyStorybook
//
//  Created by Lauren Molley on 3/15/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell:UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinningCircle: UIActivityIndicatorView!
    override var selected : Bool {
        didSet {
            self.layer.borderColor = selected ? UIColor.greenColor().CGColor : UIColor.whiteColor().CGColor
            self.layer.borderWidth = selected ? 6 : 0
        }
    }
}
