//
//  StoryViewerViewController.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos

class StoryViewerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
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
        
        // Disable tapping gestures to navigate pages
        for tapper in pager.gestureRecognizers where tapper is UITapGestureRecognizer {
            print("Disabling UIPageViewController's gesture \(tapper)")
            tapper.enabled = false
        }
        
        // Setting the currentPage updates the next and previous buttons.
        currentPage = (currentPage)
        
        self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.shadowView.layer.shadowRadius = 25
        self.shadowView.layer.shadowOpacity = 0.25
        self.shadowView.layer.borderWidth = 1
        self.shadowView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor
        
        self.shadowView.layer.shouldRasterize = true
        self.shadowView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Now the bar is hidden on the bookshelf.
        //        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    
    @IBAction internal func editStoryPageCollection(sender: AnyObject) {
        self.performSegueWithIdentifier("editSelectSegue", sender: sender)
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
        else if segue.identifier == "editSelectSegue" {
            let collection = segue.destinationViewController as! EditSelectViewController
            collection.story = self.story
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