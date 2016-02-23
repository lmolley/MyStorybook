//
//  PhotoSelectorViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class PhotoSelectorViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    var titleToDisplay:String? = ""
    var folderToDisplay:MyMomentCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleToDisplay
    }
    
}