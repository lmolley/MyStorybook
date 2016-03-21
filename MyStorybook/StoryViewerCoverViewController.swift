//
//  StoryViewerCoverViewController.swift
//  MyStorybook
//
//  Created by David Paul Quesada on 3/10/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

// A view controller for the over of an album.
class StoryViewerCoverViewController: UIViewController {
    @IBOutlet weak var square: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    internal var story: Story!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestImage(story.icon, size: CGSizeZero, synchronous: true) { (image) -> () in
            self.imageView.image = image ?? coverPhotoImageOrDefault(self.story.icon)
        }
        
        square.addAlbumBorder()
        shareButton.hideIfEmailUnavailable()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "shareStory" {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.viewControllers[0] as! EmailFavoritesViewController
            dest.story = self.story
        }
    }
}