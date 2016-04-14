//
//  EditViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/14/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos

class EditViewController: UIViewController {
    var page: Page?
    var image: UIImage?
    var origImage: UIImage?
    var text: String?
    var undo: [String?] = []
    var undoImages: [UIImage?] = []
    
    @IBOutlet var labels: [UILabel]!
    
    var emojiList = ["😀","😇","😈","😍","😎","😕","😚","😛","😡","😨","😮","😰","😱","😲","😴"]
    var frameId: String?
    var filterId: String?
    
    @IBOutlet weak var EmojiButton: UIButton!
    @IBOutlet weak var FrameButton: UIButton!
    @IBOutlet weak var FilterButton: UIButton!
    @IBOutlet weak var EditPhotoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EditPhotoImage.image = self.image
    }
    
    @IBAction func goPrevPage() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func Undo() {
        if undo.first != nil {
            switch(undo.last! ?? "") {
            case "emoji":
                self.view.subviews.last?.removeFromSuperview()
                self.labels.removeLast()
                undo.popLast()
            default:
                undoImages.popLast()
                undo.popLast()
                if undoImages.first != nil {
                    self.image = undoImages.last!
                    if (undo.last! == "red" || undo.last! == "orange" || undo.last! == "yellow" ||
                        undo.last! == "green" || undo.last! == "blue" || undo.last! == "purple") {
                        self.frameId = undo.last!
                        self.filterId = nil
                    }
                    else {
                        self.filterId = undo.last!
                        self.frameId = nil
                    }
                }
                else {
                    self.image = self.origImage
                    self.frameId = nil
                    self.filterId = nil
                }
            }
            viewDidLoad()
        }
    }
    
    func createNewEmoji() {
        let iView = self.EditPhotoImage.frame
        let iView2 = AVMakeRectWithAspectRatioInsideRect(self.image!.size, self.EditPhotoImage.frame)
        var imageViewWidthDiffHalf = (iView.size.width - iView2.size.width) / 2
        if imageViewWidthDiffHalf <= 0 {
            imageViewWidthDiffHalf = 0
        }
        var imageViewHeightDiffHalf = (iView.size.height - iView2.size.height) / 2
        if imageViewHeightDiffHalf <= 0 {
            imageViewHeightDiffHalf = 0
        }
        let imageViewOriginX = iView.origin.x + imageViewWidthDiffHalf
        let imageViewOriginY = iView.origin.y - imageViewHeightDiffHalf
        let coordX = imageViewOriginX
        let coordY = imageViewOriginY
        let label = UILabel(frame: CGRectMake(coordX, coordY, 100, 100))
        label.text = text
        label.font = label.font.fontWithSize(100)
        label.textAlignment = NSTextAlignment.Center
        label.userInteractionEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        label.addGestureRecognizer(pan)
        
        self.labels.append(label)
        self.view.addSubview(label)
        self.EditPhotoImage.bringSubviewToFront(label)
        text = ""
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        self.view.bringSubviewToFront(sender.view!)
        let translation = sender.translationInView(self.view)
        if let view = sender.view {
            var send = sender.view?.frame
            let iView = self.EditPhotoImage.frame
            let iView2 = AVMakeRectWithAspectRatioInsideRect(self.image!.size, self.EditPhotoImage.frame)
            var imageViewWidthDiffHalf = (iView.size.width - iView2.size.width) / 2
            if imageViewWidthDiffHalf <= 0 {
                imageViewWidthDiffHalf = 0
            }
            var imageViewHeightDiffHalf = (iView.size.height - iView2.size.height) / 2
            if imageViewHeightDiffHalf <= 0 {
                imageViewHeightDiffHalf = 0
            }
            let imageViewOriginX = iView.origin.x + imageViewWidthDiffHalf
            let imageViewOriginY = iView.origin.y - imageViewHeightDiffHalf
            if (send!.origin.x >= imageViewOriginX && ((send?.origin.x)! + send!.size.width <= imageViewOriginX + iView2.size.width) && send!.origin.y >= imageViewOriginY && ((send?.origin.y)! + send!.size.height <= imageViewOriginY + iView2.size.height)) {
                
                view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y)
                send = sender.view?.frame
                if (send!.origin.x < imageViewOriginX) {
                    send?.origin.x = imageViewOriginX
                }
                if ((send?.origin.x)! + (send?.size.width)! > imageViewOriginX + iView2.size.width) {
                    send?.origin.x = imageViewOriginX + iView2.size.width - (send?.size.width)!
                }
                if (send!.origin.y < iView.origin.y) {
                    send?.origin.y = iView.origin.y
                }
                if ((send?.origin.y)! + (send?.size.height)! > imageViewOriginY + iView2.size.height) {
                    send?.origin.y = imageViewOriginY + iView2.size.height - (send?.size.height)!
                }
                sender.view?.frame = send!
            }
        }
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    func finalImage() {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let oldImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(self.EditPhotoImage.frame.size, false, 0)
        oldImage.drawAtPoint(CGPointMake(self.view.frame.minX - self.EditPhotoImage.frame.minX, self.view.frame.minY - self.EditPhotoImage.frame.minY))
        let cropImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = cropImage
    }
    
    @IBAction func doneEdit(sender: UIButton) {
        //finalImage()
        if self.labels.count > 1 {
            for (var i = 1; i < labels.count; i++) {
                let em: Emoji = Emoji.init()
                em.x = Int(labels[i].frame.origin.x)
                em.y = Int(labels[i].frame.origin.y)
                em.z = 0
                em.emojiId = emojiList.indexOf(labels[i].text!)!
                em.pageId = (self.page?.id)!
                self.page?.emojis.append(em)
            }
        }
        else {
            self.page?.emojis = []
        }
        if self.frameId != nil {
            self.page?.frameId = self.frameId!
        }
        else {
            self.page?.frameId = ""
        }
        if self.filterId != nil {
            self.page?.filterId = self.filterId!
        }
        else {
            self.page?.filterId = ""
        }
        let count = (self.navigationController?.viewControllers.count)! - 3
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[count])!, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "editFrameSegue":
            let viewer = segue.destinationViewController as! EditFrameViewController
            viewer.image = self.origImage
        case "editFilterSegue":
            let viewer = segue.destinationViewController as! EditFilterViewController
            viewer.image = self.origImage
        default:
            break
        }
    }
    
    @IBAction func unwindToEditViewController(sender: UIStoryboardSegue) {
        switch (sender.identifier ?? "") {
        case "unwindEmoji":
            let viewer = sender.sourceViewController as! EditEmojiViewController
            self.text = viewer.text
            undo.append("emoji")
            createNewEmoji()
        case "unwindFrame":
            let viewer = sender.sourceViewController as! EditFrameViewController
            self.image = viewer.image
            self.frameId = viewer.frameId
            self.filterId = nil
            undo.append(viewer.frameId)
            undoImages.append(self.image)
        case "unwindFilter":
            let viewer = sender.sourceViewController as! EditFilterViewController
            self.image = viewer.image
            self.filterId = viewer.filterId
            self.frameId = nil
            undo.append(viewer.filterId)
            undoImages.append(self.image)
        default:
            break
        }
        viewDidLoad()
    }
    
    @IBAction func deleteStorybook(sender: UIButton) {
        
        let deleteAlert = UIAlertController(title: "Delete", message: "Delete Storybook?", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            //remove story from database
            App.database.removeStory((self.page?.storyId)!)
            
            //popback to bookshelf
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            
        }))
        
        presentViewController(deleteAlert, animated: true, completion: nil)
        
        /*if delete {
            //remove story from database
            App.database.removeStory((page?.storyId)!)
            
            //popback to bookshelf
            self.navigationController?.popToRootViewControllerAnimated(true)
        }*/
    }
    
}
