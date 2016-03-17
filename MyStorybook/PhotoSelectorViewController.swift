//
//  PhotoSelectorViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class PhotoSelectorViewController: UIViewController{
    
    @IBOutlet weak var titleLabel: UILabel!
    var folderToDisplay:PreStory?
    var currentPicInd:Int = 0
    var status:[Bool] = [Bool](count:4, repeatedValue:false)
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewMidLeft: UIImageView!
    @IBOutlet weak var imageViewMidRight: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!
    
    @IBAction func accept() {
//        folderToDisplay?.accepted_images.append(folderToDisplay!.images[currentPicInd]!)
//        status[0] = status[1]
//        status[1] = true
//        status[2] = status[3]
//        status[3] = false
//        
//        currentPicInd += 1
//        if currentPicInd >= folderToDisplay!.images.count {
//            performSegueWithIdentifier("SelectCoverSegue", sender: folderToDisplay)
//        }
//        else {
//            mainImageView.image = folderToDisplay!.images[currentPicInd]
//            updateBottomPics()
//        }
    }
    
    @IBAction func reject() {
//        status[0] = status[1]
//        status[1] = false
//        status[2] = status[3]
//        status[3] = false
//        
//        currentPicInd += 1
//        if currentPicInd >= folderToDisplay!.images.count {
//            print("Done!")
//            print(folderToDisplay!.accepted_images)
//            performSegueWithIdentifier("SelectCoverSegue", sender: folderToDisplay)
//        }
//        else {
//            mainImageView.image = folderToDisplay!.images[currentPicInd]
//            updateBottomPics()
//        }
    }
    
    override func viewDidLoad() {
//        super.viewDidLoad()
//        titleLabel.text = folderToDisplay?.title
//        if let mainImage = folderToDisplay!.topImage {
//            mainImageView.image = mainImage
//            imageViewMidRight.image = mainImage
//            imageViewMidRight.layer.borderColor = UIColor.yellowColor().CGColor
//            imageViewMidRight.layer.borderWidth = 3.0
//        }
//        if folderToDisplay!.images.count > 1 {
//            if let nextImage:UIImage = folderToDisplay!.images[1]{
//                imageViewRight.image = nextImage
//            }
//        }
    }
    
    private func updateBottomPics() {
//        imageViewMidRight.image = folderToDisplay!.images[currentPicInd]
//        imageViewMidRight.layer.borderColor = UIColor.yellowColor().CGColor
//        imageViewMidRight.layer.borderWidth = 3.0
//        
//        if currentPicInd - 1 >= 0 {
//            imageViewMidLeft.image = folderToDisplay!.images[currentPicInd-1]
//            addBorder(imageViewMidLeft, status: status[1])
//        }
//        
//        if currentPicInd - 2 >= 0{
//            imageViewLeft.image = folderToDisplay!.images[currentPicInd-2]
//            addBorder(imageViewLeft, status: status[0])
//        }
//        
//        if currentPicInd + 1 < folderToDisplay!.images.count {
//            imageViewRight.image = folderToDisplay!.images[currentPicInd+1]
//        }
//        else {
//            imageViewRight.image = UIImage(named: "default.jpg")
//        }
        
    }
    
    private func addBorder(imageView:UIImageView, status:Bool) {
        if status {
//            imageView.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.1)
            imageView.layer.borderColor = UIColor.greenColor().CGColor
            imageView.layer.borderWidth = 2.0
        }
        else {
            imageView.layer.borderColor = UIColor.redColor().CGColor
            imageView.layer.borderWidth = 2.0
//            imageView.tintColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectCoverSegue"
        {
            if let destinationVC = segue.destinationViewController as? CoverSelectorViewController{
                if let folder = sender as? PreStory {
                    destinationVC.story_info = folder
                }
            }
        }
    }
    
}
