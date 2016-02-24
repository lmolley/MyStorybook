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
    //********OVERRIDES FOR COLLECTION VIEW TO WORK***************
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView!) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    override func collectionView(collectionView: UICollectionView!,
        numberOfItemsInSection section: Int) -> Int {
            return icon_names.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(iconCollect_reuseIdentifier,forIndexPath: indexPath) as! IconCell
        // Configure the cell
        cell.iconView.image = coverPhotoImageOrDefault(icon_names[indexPath.row])
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let coverSelector = self.parentViewController as! CoverSelectorViewController? {
                coverSelector.story_info?.coverPhotoName = AvailableCoverPhotos[indexPath.row]
                
            }
    }
    
}
