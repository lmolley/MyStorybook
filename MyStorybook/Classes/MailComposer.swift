//
//  MailComposer.swift
//  MyStorybook
//
//  Created by Quesada, David on 3/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

import MessageUI
import Photos

class MailComposer: NSObject, MFMailComposeViewControllerDelegate {
    
    var controller: MFMailComposeViewController!
    var story: Story!
    var callback: (()->())?
    
    var subject: String?
    var toRecipients: [String]?
    
    
    init(story: Story)
    {
        self.story = story
    }
    
    internal func presentComposeSheet(onViewController viewController: UIViewController, completion: ()->())
    {
        controller = createController()
        callback = completion
        viewController.presentViewController(controller, animated: true, completion: nil)
    }

    private func createController() -> MFMailComposeViewController {
        let c = MFMailComposeViewController()
        
        let assetsFetch = PHAsset.fetchAssetsWithLocalIdentifiers(story!.pages!.map { $0.photoId }, options: nil)
        
        let opts = PHImageRequestOptions()
        opts.deliveryMode = .HighQualityFormat
        opts.synchronous = true
        
        for i in 0..<assetsFetch.count {
            let asset = assetsFetch.objectAtIndex(i) as! PHAsset
            
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, imageType, someUIOrientation, someData) -> Void in
                
                guard let imageData = imageData else {
                    print("Unable to fetch data for asset with local identifier \(asset.localIdentifier).")
                    return
                }
                guard let mimeType = mimeTypeForUTI(imageType!) else {
                    print("Can't determine MIME type for UTI \(imageType)")
                    return
                }
                
                let fileName = (someData!["PHImageFileURLKey"] as! NSURL).lastPathComponent!
                
                c.addAttachmentData(imageData, mimeType: mimeType, fileName: fileName)
                
            })
            
        }
        
        c.setMessageBody("Check out these photos!", isHTML: false)
        c.setSubject(self.subject ?? "A MyStorybook Photo Album")
        c.setToRecipients(self.toRecipients)
        
        c.mailComposeDelegate = self
        
        return c
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        if let cb = callback { cb() }
        controller.dismissViewControllerAnimated(true, completion: nil)
        callback = nil
        self.controller = nil
    }
}
