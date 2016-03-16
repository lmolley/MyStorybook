//
//  NewPhotoSelectViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 3/15/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos

let photoReuseIdentifier = "photo"
class NewPhotoSelectViewController:UICollectionViewController {
    
    var story:PreStory?
    var result: PHFetchResult?
    var images: [UIImage?]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.allowsMultipleSelection = true
        
        result = PHAsset.fetchAssetsInAssetCollection(story!.moment, options: nil)
        story!.image_ids = [String](count: result!.count, repeatedValue: "")
        images = [UIImage?](count: result!.count, repeatedValue: nil)
        
        //load images in the background
        let priority = QOS_CLASS_USER_INTERACTIVE
        for index in 0...result!.count-1 {
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                //get asset and set localIdentifier in story
                let asset = self.result?.objectAtIndex(index) as! PHAsset
                self.story!.image_ids[index] = asset.localIdentifier
                
                //Grab the image and set as cell's image
                let imageOptions = PHImageRequestOptions()
                imageOptions.deliveryMode = .HighQualityFormat
                imageOptions.synchronous = true
                var size = CGSize()
                size.width = CGFloat(asset.pixelWidth)
                size.height = CGFloat(asset.pixelHeight)
                PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFit, options: imageOptions, resultHandler: { (image, _) -> Void in
                    self.images![index] = image
                })
                dispatch_async(dispatch_get_main_queue()) {
                    let indexPath = NSIndexPath(forItem: index, inSection: 0)
                    self.collectionView!.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    //This function makes the number of cells equal to all the icons we have available
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return result!.count
    }
    
    //This function sets all the icon images
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //get the cell object
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoReuseIdentifier,forIndexPath: indexPath) as! PhotoCell
        if images![indexPath.row] == nil {
            cell.spinningCircle.startAnimating()
        }
        else {
            cell.spinningCircle.stopAnimating()
            cell.imageView.image = images![indexPath.row]
        }
        
        return cell
    }
    
    //This function sets the currently selected coverPhotoName for the story
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {

    }
}
