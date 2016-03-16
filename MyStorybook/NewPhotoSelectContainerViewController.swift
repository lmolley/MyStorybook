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
class NewPhotoSelectContainerViewController:UIViewController {
    var embeddedViewController:NewPhotoSelectViewController!
    var momentToDisplay:PHAssetCollection!

    @IBAction func clearSelection() {
        embeddedViewController.clearSelection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? NewPhotoSelectViewController
            where segue.identifier == "EmbedSegue" {
                embeddedViewController = vc
                embeddedViewController.parent = self
        }
        
        else if let destinationVC = segue.destinationViewController as? CameraRollViewController where segue.identifier == "BackToCameraRollView" {
                destinationVC.mainStory.accepted_image_ids.appendContentsOf(embeddedViewController.selectedPhotoIds)
        }
    }
    

        
}