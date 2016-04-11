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
class PhotoSelectCollectionViewController:UICollectionViewController {
    var parent: PhotoSelectViewController?
    var result: PHFetchResult?
    var image_ids: [String]?
    var images: [UIImage?]?
    var selectedPhotoIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.allowsMultipleSelection = true
        
        let moment = parent!.preStory.moment
        result = PHAsset.fetchAssetsInAssetCollection(moment, options: nil)
        image_ids = [String](count: result!.count, repeatedValue: "")
        images = [UIImage?](count: result!.count, repeatedValue: nil)
        
        // Ideally, you would use this value to take full advantage of the retina screen, but doing that makes
        // the app crash (one particular time David was testing with an album of around 40 photos). Better safe than sorry,
        // for the sake of shipping something that *probably* won't crash when being shown off.
        let scale = 1 // UIScreen.mainScreen().scale
        let targetSize = CGSize(width: scale * 290, height: scale * 246) // "Temporarily" hardcoded to the size the image views end up.
        
        //load images in the background
        let priority = QOS_CLASS_USER_INTERACTIVE
//        let max_index = result!.count < 6 ? result!.count-1 : 5
        for index in 0...result!.count-1 {
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                //get asset and set localIdentifier in story
                let asset = self.result?.objectAtIndex(index) as! PHAsset
                self.image_ids![index] = asset.localIdentifier
                //Grab the image and set as cell's image
                let imageOptions = PHImageRequestOptions()
                imageOptions.synchronous = true
                imageOptions.deliveryMode = .HighQualityFormat
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
