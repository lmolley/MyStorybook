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
    var index: Int?
    var page: Page?
    var image: UIImage?
    var origImage: UIImage?
    var text: String?
    var undo: [String?] = []
    var undoImages: [UIImage?] = []
    
    @IBOutlet weak var EmojiButton: UIButton!
    @IBOutlet weak var FrameButton: UIButton!
    @IBOutlet weak var FilterButton: UIButton!
    @IBOutlet weak var EditPhotoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EditPhotoImage.image = self.image
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func goPrevPage() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func Undo() {
        if undo.first != nil {
            switch(undo.last! ?? "") {
            case "emoji":
                self.view.subviews.last?.removeFromSuperview()
            case "frame":
                undoImages.popLast()
                if undoImages.first != nil {
                    self.image = undoImages.last!
                }
                else {
                    self.image = self.origImage
                }
            case "filter":
                undoImages.popLast()
                if undoImages.first != nil {
                    self.image = undoImages.last!
                }
                else {
                    self.image = self.origImage
                }
            default:
                break
            }
            undo.popLast()
            viewDidLoad()
        }
    }
    
    func createNewEmoji() {
        let coordX = self.EditPhotoImage.frame.minX
        let coordY = self.EditPhotoImage.frame.minY
        let label = UILabel(frame: CGRectMake(coordX, coordY, 100, 100))
        label.text = text
        label.font = label.font.fontWithSize(100)
        label.textAlignment = NSTextAlignment.Center
        label.userInteractionEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        label.addGestureRecognizer(pan)
        
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
            if (send!.origin.x >= iView.origin.x && ((send?.origin.x)! + send!.size.width <= iView.origin.x + iView.size.width) && send!.origin.y >= iView.origin.y && ((send?.origin.y)! + send!.size.height <= iView.origin.y + iView.size.height)) {
                
                view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y)
                send = sender.view?.frame
                if (send!.origin.x < iView.origin.x) {
                    send?.origin.x = iView.origin.x
                }
                if ((send?.origin.x)! + (send?.size.width)! > iView.origin.x + iView.size.width) {
                    send?.origin.x = iView.origin.x + iView.size.width - (send?.size.width)!
                }
                if (send!.origin.y < iView.origin.y) {
                    send?.origin.y = iView.origin.y
                }
                if ((send?.origin.y)! + (send?.size.height)! > iView.origin.y + iView.size.height) {
                    send?.origin.y = iView.origin.y + iView.size.height - (send?.size.height)!
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
        finalImage()
        // save photo?
        //story!.pages![self.index!] = self.page!
        self.navigationController?.popToRootViewControllerAnimated(true)
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
            undo.append("frame")
            undoImages.append(self.image)
        case "unwindFilter":
            let viewer = sender.sourceViewController as! EditFilterViewController
            self.image = viewer.image
            undo.append("filter")
            undoImages.append(self.image)
        default:
            break
        }
        viewDidLoad()
    }
}
