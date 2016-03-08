//
//  PageSelectorViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class PageSelectorViewController : UIViewController {
    var story_info:PreStory?
    
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var pageImage: UIImageView!
    var curSelectedIndex: Int?
    var count: Int = 1{
        didSet {
            pageNumber.text = String(count)
        }
    }
    
    @IBAction func confirmSelection() {
        if let index = curSelectedIndex! as Int? {
            //put selected image as page
            story_info!.page_images.append(story_info!.accepted_images[index])
            //remove selected image from showing up for next one
            story_info!.accepted_images.removeAtIndex(index)
            //update labels or finish
            if story_info!.accepted_images.count > 0 {
                count += 1
            }
            if let myImageOptions:PageCollectionViewController = self.childViewControllers[0] as? PageCollectionViewController {
                myImageOptions.collectionView!.reloadData()
                myImageOptions.viewWillAppear(true)
            }
        }
        
    }
}
