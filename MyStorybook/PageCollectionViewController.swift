//
//  ImageCollectionViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/24/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class PageCollectionViewController : UICollectionViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    //This function makes the number of cells equal to all the icons we have available
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            if let pageSelector = self.parentViewController as! PageSelectorViewController? {
                return pageSelector.story_info!.accepted_images.count
            }
            return 0
    }
    
    //This function sets all the icon images
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(iconCollect_reuseIdentifier,forIndexPath: indexPath) as! IconCell
        // Configure the cell
        if let pageSelector = self.parentViewController as! PageSelectorViewController? {
            cell.iconView.image = pageSelector.story_info!.accepted_images[indexPath.row]
        }
        else {
            cell.iconView.image = UIImage(named: "default.jpg")
        }
        
        return cell
    }
    
    //This function sets the currently selected coverPhotoName for the story
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let pageSelector = self.parentViewController as! PageSelectorViewController? {
                pageSelector.pageImage.image = pageSelector.story_info!.accepted_images[indexPath.row]
                pageSelector.curSelectedIndex = indexPath.row
            }
    }
}
