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
//        if let index = curSelectedIndex! as Int? {
//            //put selected image as page
//            story_info!.ordered_ids.append(story_info!.image_ids[index])
//            //remove selected image from showing up for next one
//            story_info!.image_ids.removeAtIndex(index)
//            story_info!.accepted_images.removeAtIndex(index)
//            //update labels or finish
//            if story_info!.accepted_images.count > 0 {
//                count += 1
//                pageImage.image = UIImage(named: "default.jpg")
//                if let myImageOptions:PageCollectionViewController = self.childViewControllers[0] as? PageCollectionViewController {
//                    myImageOptions.collectionView!.reloadData()
//                    myImageOptions.viewWillAppear(true)
//                }
//            }
//            else {
//                
//                let actualStory = Story()
//                actualStory.title = "Untitled Storybook" // What can we eventually use?
//                actualStory.icon = story_info!.coverPhotoName ?? ""
//                
//                var index = 0
//                actualStory.pages = story_info!.ordered_ids.map { photoId in
//                    let p = Page()
//                    p.number = index
//                    index += 1
//                    p.photoId = photoId
//                    return p
//                }
//                
//                App.database.createStoryWithPages(actualStory)
//                
//                self.navigationController?.popToRootViewControllerAnimated(true)
//            }
//        }
    }
}
