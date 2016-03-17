//
//  EditCollectionViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/14/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos

private let edit_reuseIdentifier = "EditCell"

class EditCollectionViewController: UICollectionViewController {
    var selectedIndex = 0
    internal var story: Story?
    
    var imageThumbnails: [UIImage?]! // In the order as the original storybook.
    var assets: [PHAsset]! // In the order as the original storybook.
    
    var displayedPages: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDisplayedPages()
        loadStoryThumbnails()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return displayedPages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(edit_reuseIdentifier, forIndexPath: indexPath) as! EditCollectionViewCell
            
        // Configure the cell
        let pageIndex = displayedPages[indexPath.item]
        
        cell.EditImage.image = UIImage(named: "default.jpg")
        cell.EditPageNum.text = "\(pageIndex)"
        
        if let thumbnail = imageThumbnails[pageIndex] {
            cell.EditImage.image = thumbnail;
        } else {
            let asset = assets[pageIndex]
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: cell.EditImage.frame.size, contentMode: .AspectFit, options: nil, resultHandler: { (image, _) -> Void in
                guard let image = image else { return }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageThumbnails[pageIndex] = image
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                })
            })
        }
            
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        selectedIndex = indexPath.item
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "editSegue":
            let viewer = segue.destinationViewController as! EditViewController
            viewer.page = story!.pages![self.selectedIndex]
        default:
            break
        }
    }
}
