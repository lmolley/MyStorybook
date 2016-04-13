//
//  BookshelfViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 3/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

class BookshelfViewController:UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        containerView.layer.borderColor = UIColor.blackColor().CGColor
    }
}