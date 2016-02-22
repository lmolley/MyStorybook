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
    
    // This will be nil if the cover page is being shown.
    private var currentPage: Int?
    
    weak var pager: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func nextPage() {
        print("next!")
        self.pager.gotoNext()
    }
    
    @IBAction func prevPage() {
        if self.currentPage != nil {
            self.pager.gotoPrev()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPager"
        {
            pager = segue.destinationViewController as! UIPageViewController
            pager.dataSource = self
//            pager.delegate = self // I don't think we need any of the delegate functionality yet.
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
        return self.storyboard!.instantiateViewControllerWithIdentifier("storyViewerCoverPage") as! StoryViewerCoverViewController
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
        case let page as StoryViewerPhotoPageViewController:
            return createPhotoPageViewController(page.pageIndex + 1)
        default:
            fatalError("Invalid view controller in StoryViewerViewController pageViewController:viewControllerAfterViewController")
        }
    }
}

extension UIPageViewController
{
    func gotoNext()
    {
        let current = self.viewControllers![0]
        let next = self.dataSource!.pageViewController(self, viewControllerAfterViewController: current)!
        
        self.setViewControllers([next], direction: .Forward, animated: true, completion: nil)
    }
    
    func gotoPrev()
    {
        let current = self.viewControllers![0]
        let prev = self.dataSource!.pageViewController(self, viewControllerBeforeViewController: current)!
        
        self.setViewControllers([prev], direction: .Reverse, animated: true, completion: nil)
    }
}

// A view controller for the over of an album.
class StoryViewerCoverViewController: UIViewController {
    
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