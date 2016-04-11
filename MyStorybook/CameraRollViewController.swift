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
    
    @IBOutlet weak var acceptButton: UIControl!
    
    @IBOutlet weak var numberSelectedLabel: UILabel!
    var numberSelected:Int = 0 {
        didSet {
            if numberSelected == 0 {
                numberSelectedLabel.text = ""
                acceptButton.hidden = true
            }
            else {
                numberSelectedLabel.text = String(numberSelected)
                acceptButton.hidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        numberSelected = self.mainStory.accepted_image_ids.count
    }
    
    @IBAction func finished() {
        print("SAVING")
        let actualStory = Story()
        actualStory.title = mainStory.title ?? "Untitled Storybook" // What can we eventually use?
        actualStory.icon = mainStory.accepted_image_ids.first ?? "" //set icon as first image for now
        var index = 0
        actualStory.pages = mainStory.accepted_image_ids.map { photoId in
                                let p = Page()
                                p.number = index
                                index += 1
                                p.photoId = photoId
                                return p
                            }
            
        App.database.createStoryWithPages(actualStory)
        performSegueWithIdentifier("SelectionDoneSegue", sender:actualStory)
    }
    
    @IBAction func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectionDoneSegue"
        {
            if let destinationVC = segue.destinationViewController as? StoryViewerViewController{
                if let story = sender as? Story {
                    destinationVC.story = story
                }
            }
        }
    }
    
     @IBAction func unwindToCameraRoll(segue: UIStoryboardSegue) {
        print(mainStory.accepted_image_ids)
        numberSelected = mainStory.accepted_image_ids.count
    }

    
}
