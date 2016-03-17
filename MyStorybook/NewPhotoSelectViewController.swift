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
    var parent: NewPhotoSelectContainerViewController?
    var result: PHFetchResult?
    var image_ids: [String]?
    var images: [UIImage?]?
    var selectedPhotoIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.allowsMultipleSelection = true
        
        let moment = parent!.momentToDisplay
        result = PHAsset.fetchAssetsInAssetCollection(moment, options: nil)
        image_ids = [String](count: result!.count, repeatedValue: "")
        images = [UIImage?](count: result!.count, repeatedValue: nil)
        
        //load images in the background
        let priority = QOS_CLASS_USER_INTERACTIVE
        for index in 0...result!.count-1 {
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                //get asset and set localIdentifier in story
                let asset = self.result?.objectAtIndex(index) as! PHAsset
                self.image_ids![index] = asset.localIdentifier
                
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
    

    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return result!.count
    }
    
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
    

    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            selectedPhotoIds.append(image_ids![indexPath.row])
    }
    
    override func collectionView(collectionView: UICollectionView,
        didDeselectItemAtIndexPath indexPath: NSIndexPath) {
            if let foundIndex = selectedPhotoIds.indexOf(image_ids![indexPath.row]) {
                selectedPhotoIds.removeAtIndex(foundIndex)
            }
    }
    
    func clearSelection(){
        selectedPhotoIds = [String]()
        self.collectionView!.reloadData()
    }
}
