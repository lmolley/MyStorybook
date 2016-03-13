//
//  StoryViewerViewController.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos
import MessageUI

class StoryViewerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    internal var story: Story?
    
    // This will be nil if the cover page is being shown.
    private var currentPage: Int?
    {
        didSet
        {
            if (currentPage == nil) { // On cover page
                prevButton.hidden = true
                nextButton.hidden = (pageCount <= 0)
            } else // On photo page
            {
                prevButton.hidden = false
                nextButton.hidden = (currentPage >= pageCount - 1)
            }
        }
    }
    
    private var pageCount: Int
    {
        get
        {
            return story?.pages?.count ?? 0
        }
    }
    
    weak var pager: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting the currentPage updates the next and previous buttons.
        currentPage = (currentPage)
        
        self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.shadowView.layer.shadowRadius = 25
        self.shadowView.layer.shadowOpacity = 0.25
        self.shadowView.layer.borderWidth = 1
        self.shadowView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor
        
        if !MFMailComposeViewController.canSendMail() {
            print("Device cannot send emails, hiding share button.")
            shareButton.hidden = true
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction internal func share() {
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
        c.setSubject("A MyStorybook Photo Album")
        
        c.mailComposeDelegate = self
        
        self.presentViewController(c, animated: true, completion: nil)
    }
    
    @IBAction func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func nextPage() {
        self.pager.gotoNext()
        self.currentPage = (currentPage ?? -1) + 1
    }
    
    @IBAction func prevPage() {
        if self.currentPage != nil {
            self.pager.gotoPrev()
            self.currentPage = (currentPage! > 0) ? currentPage! - 1 : nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPager"
        {
            pager = segue.destinationViewController as! UIPageViewController
            pager.dataSource = self
            pager.delegate = self
            showPage(nil) // Show the storybook cover.
        }
    }
    
    func showPage(page: Int?) {
        
        var vc: UIViewController
        
        if let pageVal = page {
            vc = createPhotoPageViewController(pageVal)
        } else {
            vc = createCoverViewController()
        }
        
        pager.setViewControllers([vc], direction: .Forward, animated: false, completion: nil)
    }
    
    func createCoverViewController() -> StoryViewerCoverViewController
    {
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("storyViewerCoverPage") as! StoryViewerCoverViewController
        viewController.story = self.story
        return viewController
    }
    
    func createPhotoPageViewController(pageIndex: Int) -> StoryViewerPhotoPageViewController
    {
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("storyViewerPhotoPage") as! StoryViewerPhotoPageViewController
        viewController.pageIndex = pageIndex
        viewController.page = self.story?.pages![pageIndex]
        return viewController
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        switch (viewController)
        {
        case is StoryViewerCoverViewController:
            return nil
        case let page as StoryViewerPhotoPageViewController where page.pageIndex == 0:
            return createCoverViewController()
        case let page as StoryViewerPhotoPageViewController where page.pageIndex > 0:
            return createPhotoPageViewController(page.pageIndex - 1)
        default:
            fatalError("Invalid view controller in StoryViewerViewController pageViewController:viewControllerBeforeViewController")
        }
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        switch (viewController)
        {
        case is StoryViewerCoverViewController:
            return createPhotoPageViewController(0)
        case let page as StoryViewerPhotoPageViewController where page.pageIndex < (pageCount - 1):
            return createPhotoPageViewController(page.pageIndex + 1)
        case let page as StoryViewerPhotoPageViewController where page.pageIndex == pageCount - 1:
            return nil
        default:
            fatalError("Invalid view controller in StoryViewerViewController pageViewController:viewControllerAfterViewController")
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let vc = pageViewController.viewControllers![0]
        self.currentPage = (vc as? StoryViewerPhotoPageViewController)?.pageIndex
    }
}

internal func mimeTypeForUTI(uti: String) -> String? {
    switch (uti) {
    case "public.jpeg": return "image/jpeg"
    case "public.png": return "image/png"
    case "public.tiff": return "image/tiff"
    default:
        return nil
    }
}