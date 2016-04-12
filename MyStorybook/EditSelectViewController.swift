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
    
    @IBOutlet weak var editCollection: UICollectionView!
    
    internal var story: Story?
    internal var page: Page?
    
    var imageThumbnails: [UIImage?]! // In the order as the original storybook.
    var assets: [PHAsset]! // In the order as the original storybook.
    
    var displayedPages: [Int]!
    
    var image: UIImage?
    
    private var _image: UIImage! {
        willSet {
        }
        
        didSet {
            self.image = _image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editCollection.dataSource = self
        editCollection.delegate = self
        
        setupDisplayedPages()
        loadStoryThumbnails()
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
        
        // The result from fetchAssetsWithLocalIdentifiers doesn't put the assets in the same order as you request them, so build a lookup dictionary for them.
        var lookup = [String:PHAsset]()
        
        for i in 0 ..< fetchResult.count {
            let asset = fetchResult.objectAtIndex(i) as! PHAsset
            lookup[asset.localIdentifier] = asset
        }
        
        assets = ids.map { lookup[$0]! }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch (segue.identifier ?? "")
        {
        case "editPhotoSegue":
            
            guard let cell = sender as? EditCollectionViewCell else { fatalError("EditSelectViewController segue 'editPhotoSegue' must have EditCollectionViewCell as sender.") }
            
            guard let selectedIndex = editCollection.indexPathForCell(cell)?.item else { fatalError("Sender cell is not in the collection view?") }
            
            let viewer = segue.destinationViewController as! EditViewController
            viewer.page = story!.pages![selectedIndex]
            
            let opts = PHFetchOptions()
            let result = PHAsset.fetchAssetsWithLocalIdentifiers([viewer.page!.photoId], options: opts)
            let asset = result.objectAtIndex(0) as! PHAsset
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let opts2 = PHImageRequestOptions()
            opts2.synchronous = true
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFit, options: opts2) { (image, info) -> Void in
                self._image = image!
            }
            
            if viewer.image != self._image {
                viewer.image = self._image
                viewer.origImage = viewer.image
            }
            else {
                viewer.image = UIImage(named:"default.jpg")
                viewer.origImage = viewer.image
            }
        default:
            break
        }
    }
    
    
}