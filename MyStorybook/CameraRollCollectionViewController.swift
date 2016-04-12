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

let moment_reuseIdentifier = "MomentCell"
let headerViewIdentifier = "HeaderView"

class CameraRollCollectionViewController : UICollectionViewController{
    let formatter = NSDateFormatter()
    let yearFormatter = NSDateFormatter()
    var years = [String:Array<PreStory>]()
    var year_order = [String]()
    var image_count:Int = 0
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    var maxImageCount:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.allowsMultipleSelection = true
        formatter.dateFormat = "MMM d"
        yearFormatter.dateFormat = "Y"
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
                
                let yearString = self.yearFormatter.stringFromDate(new_folder.moment.startDate!)
                //check if we already mapped this year
                if (self.years[yearString]) != nil {
                    self.years[yearString]!.append(new_folder)
                    self.fetchFirstPhotoInMoment(yearString, rowIndex: self.years[yearString]!.count-1)
                }
                //if not, map the year and initialize with empty array
                else {
                    self.year_order.append(yearString)
                    var initialStoriesForYear = [PreStory]()
                    initialStoriesForYear.append(new_folder)
                    self.years[yearString] = initialStoriesForYear
                    self.fetchFirstPhotoInMoment(yearString, rowIndex: 0)
                }
                
            }
        })
    }
    
    // Returns true if the moment has at least one photo
    private func fetchFirstPhotoInMoment(yearString:String, rowIndex:Int)-> Bool
    {
        let folder = self.years[yearString]![rowIndex]
        let opts = PHFetchOptions()
        opts.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        opts.fetchLimit = 3
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(folder.moment, options: opts)
        
        if fetchResult.count == 0 {
            return false
        }
        
        let indexPath = NSIndexPath(forItem: rowIndex, inSection: year_order.indexOf(yearString)!)
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
            return years.count
    }
    
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            //return number of images in our 1 section
        let sectionKey = year_order[section]
        return years[sectionKey]!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(moment_reuseIdentifier,forIndexPath: indexPath) as! CameraRollCollectionViewCell
        let rowKey = year_order[indexPath.section]
        let stories = years[rowKey]
        let story = stories![indexPath.row]
            
        // Configure the cell
        cell.checkMark.hidden = true
        cell.dateLabel.text = formatter.stringFromDate(story.moment.startDate!)
        
        cell.bottomImageView.image = story.bottomImage ?? UIImage(named: "default.jpg")
        cell.middleImageView.image = story.middleImage ?? UIImage(named: "default.jpg")
        cell.topImageView.image = story.topImage ?? UIImage(named: "default.jpg")
        
        cell.setNeedsLayout()
        cell.setNeedsUpdateConstraints()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let rowKey = year_order[indexPath.section]
        let stories = years[rowKey]
        let story = stories![indexPath.row]
        performSegueWithIdentifier("PhotoSelectorSegue", sender: story)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView: CameraRollHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerViewIdentifier, forIndexPath: indexPath) as! CameraRollHeader
        headerView.sectionLabel.text = year_order[indexPath.section]
        return headerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoSelectorSegue"
        {
            if let destinationVC = segue.destinationViewController as? PhotoSelectViewController{
                if let folder = sender as? PreStory {
                    destinationVC.preStory = folder
                }
            }
        }
    }
    
}