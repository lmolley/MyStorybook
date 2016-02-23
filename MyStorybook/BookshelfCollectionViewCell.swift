//
//  BookshelfCollectionViewCell.swift
//  MyStorybook
//
//  Created by Rachel Choi on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class BookshelfCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var Cover: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let view = self.viewWithTag(12345)
        {
            view.addAlbumBorder()
        }
    }
}

