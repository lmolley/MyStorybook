//
//  EditSelectViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/17/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos

private let edit_reuseIdentifier = "EditCell"

class EditSelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var selectedIndex = -1
    
    @IBOutlet weak var editCollection: UICollectionView!
    
    internal var story: Story?
    internal var page: Page?
    
    var imageThumbnails: [UIImage?]! // In the order as the original storybook.
    var assets: [PHAsset]! // In the order as the original storybook.
    
    var displayedPages: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editCollection.dataSource = self
        editCollection.delegate = self
        
        setupDisplayedPages()
        loadStoryThumbnails()
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
    
    func setupDisplayedPages()
    {
        guard let story = story else {
            fatalError("self.story must be set upon view loading.")
        }
            
        displayedPages = [Int](0 ..< (story.pages?.count ?? 0))
        
        guard let pages = story.pages else {
            return
        }
            
        let ids = pages.map { $0.photoId }
        let assetOptions = PHFetchOptions()
            
        let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers(ids, options: assetOptions)
            
        assets = []
            
        for i in 0 ..< fetchResult.count {
            let asset = fetchResult.objectAtIndex(i) as! PHAsset
            assets.append(asset)
        }
    }
        
    func loadStoryThumbnails()
    {
        guard let story = story else {
            fatalError("self.story must be set upon view loading.")
        }
        
        imageThumbnails = Array<UIImage?>(count: story.pages?.count ?? 0, repeatedValue: nil)
    }
        
    // MARK: UICollectionViewDataSource
        
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPages.count
    }
        
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(edit_reuseIdentifier, forIndexPath: indexPath) as! EditCollectionViewCell
            
        // Configure the cell
        let pageIndex = displayedPages[indexPath.item]
            
        cell.EditImage.image = UIImage(named: "default.jpg")
        cell.EditPageNum.text = "\(indexPath.item + 1)" // The displayed page number is defined by the index path, not by the photo index in the original story.
            
        if let thumbnail = imageThumbnails[pageIndex] {
            cell.EditImage.image = thumbnail;
        } /*else {
            let asset = assets[pageIndex]
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: cell.EditImage.frame.size, contentMode: .AspectFit, options: nil, resultHandler: { (image, _) -> Void in
                guard let image = image else { return }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageThumbnails[pageIndex] = image
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                })
            })
        }*/
            
        return cell
    }
        
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
        
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
            
        let from = sourceIndexPath.item
        let to = destinationIndexPath.item
            
        let oldIndex = displayedPages.removeAtIndex(from)
        displayedPages.insert(oldIndex, atIndex: to)
            
        // Update the displayed page numbers.
        for visibleIdx in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(visibleIdx) as! EditCollectionViewCell
            cell.EditPageNum.text = "\(visibleIdx.item + 1)"
        }
    }
        
    // MARK: UICollectionViewDelegate
        
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        self.selectedIndex = indexPath.item
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.layer.borderWidth = 1.0
        cell?.layer.borderColor = UIColor.greenColor().CGColor
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.layer.borderWidth = 0.0
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "editPhotoSegue":
            if self.selectedIndex != -1 {
                let viewer = segue.destinationViewController as! EditViewController
                viewer.page = story!.pages![self.selectedIndex]
                viewer.index = self.selectedIndex
                if let imageExist = self.imageThumbnails[displayedPages[self.selectedIndex]] {
                    viewer.image = imageExist
                }
                else {
                    viewer.image = UIImage(named: "default.jpg")
                }
            }
            else {
                let attributedString = NSAttributedString(string: "X", attributes: [
                    NSFontAttributeName : UIFont.systemFontOfSize(40),
                    NSForegroundColorAttributeName : UIColor.redColor()
                    ])
                let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                alert.setValue(attributedString, forKey: "attributedMessage")
                
                self.presentViewController(alert, animated: true, completion: nil)
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {alert.dismissViewControllerAnimated(true, completion: nil)})
            }
        default:
            break
        }
    }
}

