//
//  NewPhotoSelectViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 3/15/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

let photoReuseIdentifier = "photo"
class NewPhotoSelectViewController:UICollectionViewController {
    var folderToDisplay:PreStory?
    
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    //This function makes the number of cells equal to all the icons we have available
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return (folderToDisplay?.image_ids.count)!
    }
    
    //This function sets all the icon images
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoReuseIdentifier,forIndexPath: indexPath) as! PhotoCell
        // Configure the cell
        cell.imageView.image = folderToDisplay?.images[indexPath.row]
        return cell
    }
    
    //This function sets the currently selected coverPhotoName for the story
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {

    }
}
