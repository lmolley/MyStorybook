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
    var momentToDisplay:PHAssetCollection!

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
                destinationVC.mainStory.accepted_image_ids.appendContentsOf(embeddedViewController.selectedPhotoIds)
        }
    }
    

        
}