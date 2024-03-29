//
//  ViewExtensions.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension UIView
{
    /// Adds a dark red border and a shadow to this view.
    public func addAlbumBorder()
    {
        layer.borderColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1.0).CGColor
        layer.borderWidth = 7
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 13
        layer.shadowOpacity = 0.5
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    public func hideIfEmailUnavailable()
    {
        if !MFMailComposeViewController.canSendMail() {
            print("Device cannot send emails, hiding \(self).")
            self.hidden = true
        }
    }
}