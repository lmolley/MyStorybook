//
//  IconCollectionViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

let iconCollect_reuseIdentifier = "MyIconCell"

class IconCollectionViewController : UICollectionViewController {
    var icon_names:[String] = AvailableCoverPhotos
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }

    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView!) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    //This function makes the number of cells equal to all the icons we have available
    override func collectionView(collectionView: UICollectionView!,
        numberOfItemsInSection section: Int) -> Int {
            return icon_names.count
    }
    
    //This function sets all the icon images
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(iconCollect_reuseIdentifier,forIndexPath: indexPath) as! IconCell
        // Configure the cell
        cell.iconView.image = coverPhotoImageOrDefault(icon_names[indexPath.row])
        return cell
    }
    
    //This function sets the currently selected coverPhotoName for the story
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let coverSelector = self.parentViewController as! CoverSelectorViewController? {
                coverSelector.displayImage.image = coverPhotoImageOrDefault(icon_names[indexPath.row])
                coverSelector.story_info?.coverPhotoName = AvailableCoverPhotos[indexPath.row]
                
            }
    }
    
}
