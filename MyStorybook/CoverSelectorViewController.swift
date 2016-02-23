//
//  File.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class CoverSelectorViewController: UIViewController {
        var story_info:PreStory?
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
            performSegueWithIdentifier("SelectPageSegue", sender: story_info)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectPageSegue"
        {
            if let destinationVC = segue.destinationViewController as? PageSelectorViewController{
                if let folder = sender as? PreStory {
                    destinationVC.story_info = folder
                }
            }
        }
    }
}
