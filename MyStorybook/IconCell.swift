//
//  IconCell.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class IconCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }
    
    override var selected : Bool {
        didSet {
            self.layer.borderColor = selected ? UIColor.redColor().CGColor : UIColor.whiteColor().CGColor
            self.layer.borderWidth = selected ? 2 : 0
        }
    }
}