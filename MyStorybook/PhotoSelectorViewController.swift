//
//  PhotoSelectorViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
let bottomCell_reuseIdentifier = "bottomSliderCell"

class PhotoSelectorViewController: UICollectionViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    var titleToDisplay:String? = ""
    var folderToDisplay:MyMomentCollection?
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBAction func accept() {
    }
    
    @IBAction func reject() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleToDisplay
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
            return (folderToDisplay?.images.count)!
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bottomCell_reuseIdentifier,forIndexPath: indexPath) as! bottomSliderCell
        
        // Configure the cell
        cell.imageView.image = folderToDisplay.images[indexPath.row]
        return cell
    }
    
}
