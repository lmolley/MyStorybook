//
//  FinishedViewController.swift
//  MyStorybook
//
//  Created by Molley, Lauren on 3/7/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class FinishedViewController : UIViewController {
    
    @IBAction func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
