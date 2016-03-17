//
//  EditContainerViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/17/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

var tap = false

class EditContainerViewController: UIViewController {
    var story: Story?
    var page: Page?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "editCollectionSegue":
            let viewer = segue.destinationViewController as! EditCollectionViewController
            viewer.story = self.story
        case "editPhotoSegue":
            if tap == true {
            let viewer = segue.destinationViewController as! EditViewController
            viewer.page = self.page
            }
            else {
                let alert = UIAlertController(title: "X", message: "", preferredStyle: .Alert)
                self.presentViewController(alert, animated: true, completion: nil)
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        default:
            break
        }

    }
}
