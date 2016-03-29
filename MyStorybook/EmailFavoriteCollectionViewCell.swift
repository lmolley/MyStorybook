//
//  EmailFavoriteCollectionViewCell.swift
//  MyStorybook
//
//  Created by Quesada, David on 3/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class EmailFavoriteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.layer.cornerRadius = (self.imageView.frame.size.width / 2)
        
        self.imageView.layer.masksToBounds = true
    }
}
