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
    
    internal var story: Story!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = coverPhotoImageOrDefault(story.icon)
        
        square.addAlbumBorder()
    }
    
    @IBAction func shareInStoryViewerAncestor() {
        let viewer = self.parentViewController?.parentViewController as! StoryViewerViewController
        
        viewer.share()
    }
}