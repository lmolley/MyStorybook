//
//  UIPageViewControllerExtensions.swift
//  MyStorybook
//
//  Created by David Paul Quesada on 3/10/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

extension UIPageViewController
{
    // Animates a transition to the next view controller.
    func gotoNext()
    {
        let current = self.viewControllers![0]
        let next = self.dataSource!.pageViewController(self, viewControllerAfterViewController: current)!
        
        self.setViewControllers([next], direction: .Forward, animated: true, completion: nil)
    }
    
    // Animates a transition to the previous view controller.
    func gotoPrev()
    {
        let current = self.viewControllers![0]
        let prev = self.dataSource!.pageViewController(self, viewControllerBeforeViewController: current)!
        
        self.setViewControllers([prev], direction: .Reverse, animated: true, completion: nil)
    }
}