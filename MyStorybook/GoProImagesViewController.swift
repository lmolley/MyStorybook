//
//  GoProImagesViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit
import Photos

let GoPro_reuseIdentifier = "GoProImageCell"

class GoProImagesViewController : UICollectionViewController {
    var preStories = [PreStory]()
    var image_count:Int = 0
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    var maxImageCount:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMomentsFromCameraRoll()
    }
    
    private func fetchMomentsFromCameraRoll () {
        print("about to fetch!")
        maxImageCount = 50
        
        let collectionFetchOptions = PHFetchOptions()
        collectionFetchOptions.sortDescriptors = [NSSortDescriptor(key:"startDate", ascending: false)]
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Moment, subtype: .Any, options: collectionFetchOptions)
        
        smartAlbums.enumerateObjectsUsingBlock({
            
            if let collection = $0.0 as? PHAssetCollection {
                
                let new_folder = PreStory(title_in: collection.localizedTitle, date_in: collection.startDate)
                
                new_folder.moment = collection
                
                // Begin attempt to get the top image. If there is none, don't bother with the moment. (Would there ever be a moment without an image?)
                self.preStories.append(new_folder)
                self.fetchFirstPhotoInMoment(self.preStories.count-1)
            }
        })
    }
    
    // Returns true if the moment has at least one photo
    private func fetchFirstPhotoInMoment(folder_index:Int)-> Bool
    {
        let folder = self.preStories[folder_index]
        let opts = PHFetchOptions()
        opts.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        opts.fetchLimit = 3
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(folder.moment, options: opts)
        
        if fetchResult.count == 0 {
            return false
        }
        
        let indexPath = NSIndexPath(forItem: folder_index, inSection: 0)
        for index in 0...2 {
            if fetchResult.count <= index {
                break
            }
            let asset = fetchResult.objectAtIndex(index) as! PHAsset
            let imageOptions = PHImageRequestOptions()
            imageOptions.synchronous = false

            let size = CGSizeMake(200, 200)
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFit, options: imageOptions) { (image, info) -> Void in
                
                if image != nil {
                    switch(index){
                    case 0:folder.topImage = image
                    case 1:folder.middleImage = image
                    case 2:folder.bottomImage = image
                    default:break
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                    }
                }
            }
                
        }
        
        return true
    }
    

    
//********OVERRIDES FOR COLLECTION VIEW TO WORK***************
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            //return number of images in our 1 section
            return preStories.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoPro_reuseIdentifier,forIndexPath: indexPath) as! GoProImageCollectionViewCell
        let story = preStories[indexPath.row]
            
        // Configure the cell
//        cell.titleLabel.text = story.title
//        cell.dateLabel.text = getDate(story.date!)
        
        if (preStories.count > indexPath.row) {
            cell.bottomImageView.image = story.bottomImage ?? UIImage(named: "default.jpg")
            cell.middleImageView.image = story.middleImage ?? UIImage(named: "default.jpg")
            cell.topImageView.image = story.topImage ?? UIImage(named: "default.jpg")
            


        }
        else {
            cell.bottomImageView.image = UIImage(named: "default.jpg")
            cell.middleImageView.image = UIImage(named: "default.jpg")
            cell.topImageView.image = UIImage(named: "default.jpg")
        }
        
        // TODO: FIXME: For some reason, the text labels in the cells randomly fail to appear sometimes.
        cell.setNeedsLayout()
        cell.setNeedsUpdateConstraints()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let story = preStories[indexPath.row]
        performSegueWithIdentifier("PhotoSelectorSegue", sender: story)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoSelectorSegue"
        {
            if let destinationVC = segue.destinationViewController as? NewPhotoSelectViewController{
                if let folder = sender as? PreStory {
                    destinationVC.story = folder
                }
            }
        }
    }
    private func getDate(date:NSDate)->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.stringFromDate(date)
    }
    
}