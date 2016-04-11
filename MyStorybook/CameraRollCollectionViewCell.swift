//
//  GoProImageCollectionViewCell.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

class CameraRollCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var checkMark: UILabel!

    @IBOutlet weak var topImageView: UIImageView!
    
    @IBOutlet weak var middleImageView: UIImageView!
    
    @IBOutlet weak var bottomImageView: UIImageView!
    
    override var selected : Bool {
        didSet {
            self.checkMark.hidden = !selected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkMark.layer.cornerRadius = 15
        checkMark.layer.masksToBounds = true
    }
    
}