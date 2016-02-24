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
    var selectedIconPath:NSIndexPath?
    var selectedCell:IconCell?
    
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
            //return number of images in our 1 section
            //            return camera_roll_images.count
            //            return image_count
            return icon_names.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(iconCollect_reuseIdentifier,forIndexPath: indexPath) as! IconCell
        
        //start with first icon selected
        if indexPath.row == 1 {
            updateSelected(cell, cell_to_undecorate: nil, ind: indexPath)
        }
        // Configure the cell
        cell.iconView.image = coverPhotoImageOrDefault(icon_names[indexPath.row])
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(iconCollect_reuseIdentifier,forIndexPath: indexPath) as! IconCell
        updateSelected(cell, cell_to_undecorate: selectedCell, ind: indexPath)
    }
    
    func updateSelected(cell_to_decorate:IconCell?, cell_to_undecorate:IconCell?, ind:NSIndexPath) {
        if let undecorate = cell_to_undecorate as IconCell! {
            undecorate.layer.borderColor = UIColor.whiteColor().CGColor
            undecorate.layer.borderWidth = 0
            self.collectionView!.reloadItemsAtIndexPaths([selectedIconPath!])
            if selectedCell == undecorate{
                selectedCell = nil
                selectedIconPath = nil
                return
            }
        }
        if let decorate = cell_to_decorate as IconCell! {
            decorate.layer.borderColor = UIColor.redColor().CGColor
            decorate.layer.borderWidth = 2
            self.collectionView!.reloadItemsAtIndexPaths([ind])
            selectedCell = decorate
            selectedIconPath = ind
        }
        
        print(selectedCell)
        print(selectedIconPath)
    }

}
