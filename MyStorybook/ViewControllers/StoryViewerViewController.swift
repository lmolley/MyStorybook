//
//  StoryViewerViewController.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class StoryViewerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension UIPageViewController
{
    // Animates a transition to the next view controller.
    func gotoNext()
    {
        let current = self.viewControllers![0]
        let next = self.dataSource!.pageViewController(self, viewControllerAfterViewController: current)!
        
        self.setViewControllers([next], direction: .Forward, animated: true, completion: nil)
    }
    
    // Animates a transition to the previous view controller.
    func gotoPrev()
    {
        let current = self.viewControllers![0]
        let prev = self.dataSource!.pageViewController(self, viewControllerBeforeViewController: current)!
        
        self.setViewControllers([prev], direction: .Reverse, animated: true, completion: nil)
    }
}

// A view controller for the over of an album.
class StoryViewerCoverViewController: UIViewController {
    @IBOutlet weak var square: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    internal var story: Story!
    {
        didSet
        {

        }
    }
    
    static var defaultCoverImage: UIImage
    {
        get
        {
            return UIImage(named: "file-folder-md")!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = StoryViewerCoverViewController.defaultCoverImage
        
                    self.imageView.image = UIImage(named: "CoverPhotos/\(story.icon)") ?? StoryViewerCoverViewController.defaultCoverImage
        
        square.layer.borderColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1.0).CGColor
        square.layer.borderWidth = 7
        square.layer.shadowColor = UIColor.blackColor().CGColor
        square.layer.shadowRadius = 17
        square.layer.shadowOpacity = 0.5
    }
}

// A view controller for one page of the album.
class StoryViewerPhotoPageViewController: UIViewController {
    internal var pageIndex: Int = 0
    @IBOutlet weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberLabel.text = "\(pageIndex + 1)"
    }
}