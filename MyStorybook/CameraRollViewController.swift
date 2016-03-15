//
//  CameraRollViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 3/15/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class CameraRollViewController:UIViewController {
    var mainStory = PreStory(title_in: "Tommy's Storybook", date_in: NSDate())
    
    @IBAction func finished() {
        performSegueWithIdentifier("SelectionDoneSegue", sender:nil)
    }
    
    @IBAction func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectionDoneSegue"
        {
            if let destinationVC = segue.destinationViewController as? PhotoSelectorViewController{
                if let folder = sender as? PreStory {
                    destinationVC.folderToDisplay = folder
                }
            }
        }
    }

    
}
