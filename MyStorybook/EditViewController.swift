//
//  EditViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/14/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    var page: Page?
    
    @IBOutlet weak var EmojiButton: UIButton!
    @IBOutlet weak var DrawButton: UIButton!
    @IBOutlet weak var FilterButton: UIButton!
    @IBOutlet weak var EditPhotoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EditPhotoImage.image = UIImage(named: "default.jpg")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "editSegue":
            let viewer = segue.destinationViewController as! EditViewController
            viewer.page = self.page
        default:
            break
        }
    }
}
