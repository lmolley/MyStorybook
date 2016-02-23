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
    var titleToDisplay:String? = ""
    var folderToDisplay:MyMomentCollection?
    var currentPicInd:Int = 0
    var acceptedImages:[UIImage] = [UIImage]()
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewMidLeft: UIImageView!
    @IBOutlet weak var imageViewMidRight: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!
    
    @IBAction func accept() {
        acceptedImages.append(folderToDisplay!.images[currentPicInd])
        currentPicInd += 1
        if currentPicInd >= folderToDisplay!.images.count {
            print("Done!")
            print(acceptedImages)
        }
        else {
            mainImageView.image = folderToDisplay!.images[currentPicInd]
        }
    }
    
    @IBAction func reject() {
        currentPicInd += 1
        if currentPicInd >= folderToDisplay!.images.count {
            print("Done!")
            print(acceptedImages)
        }
        else {
            mainImageView.image = folderToDisplay!.images[currentPicInd]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleToDisplay
        if folderToDisplay!.images.count < 4 {
            //TODO: add display choices here
        }
        else {
            mainImageView.image = folderToDisplay!.images[0]
            imageViewLeft.image = folderToDisplay!.images[0]
            imageViewMidLeft.image = folderToDisplay!.images[1]
            imageViewMidRight.image = folderToDisplay!.images[2]
            imageViewRight.image = folderToDisplay!.images[3]
        }
    }
    
}
