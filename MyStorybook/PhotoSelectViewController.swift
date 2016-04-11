//
//  NewPhotoSelectContainerViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 3/16/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit
import Photos
class PhotoSelectViewController:UIViewController {
    var embeddedViewController:PhotoSelectCollectionViewController!
    var preStory: PreStory!
    
    private var momentToDisplay:PHAssetCollection! {
        get {
            return preStory.moment
        }
    }
    
    @IBAction func clearSelection() {
        embeddedViewController.clearSelection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PhotoSelectCollectionViewController
            where segue.identifier == "EmbedSegue" {
                embeddedViewController = vc
                embeddedViewController.parent = self
        }
        
        else if let destinationVC = segue.destinationViewController as? CameraRollViewController where segue.identifier == "BackToCameraRollView" {
            
            let main = destinationVC.mainStory
            
            var imagesInThisMoment = Set<String>()
            let result = PHAsset.fetchAssetsInAssetCollection(preStory.moment, options: nil)
            for i in 0..<result.count {
                let asset = result.objectAtIndex(i) as! PHAsset
                imagesInThisMoment.insert(asset.localIdentifier)
            }
            
            // Remove the existing images in the main story that came from this moment.
            main.accepted_image_ids = main.accepted_image_ids.filter { !imagesInThisMoment.contains($0) }
            
            // Add to the end the new set of photos from this moment that the user wants.
            main.accepted_image_ids.appendContentsOf(embeddedViewController.selectedPhotoIds)
        }
    }
    

        
}