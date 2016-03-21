//
//  BookshelfCollectionViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "BookCell"
private let reuseIdentifier2 = "AddCell"
private let reuseIdentifier3 = "CameraCell"

internal func requestImage(identifier: String, var size: CGSize, synchronous: Bool, completion: (UIImage?)->())
{
    let af = PHAsset.fetchAssetsWithLocalIdentifiers([identifier], options: nil)
    
    if af.count == 0 {
        print("Can't find asset with identifier \(identifier)")
    }
    
    let asset = af.objectAtIndex(0) as! PHAsset
    
    if size == CGSizeZero {
        size = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
    }
    
    let opts = PHImageRequestOptions()
    opts.synchronous = synchronous
    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFit, options: opts) { (image, _) -> Void in
        completion(image)
    }
}

class BookshelfCollectionViewController: UICollectionViewController {

    var selectedIndex = 0
    var stories = [Story]()
    var images = [UIImage?]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        stories = App.database.getStories()
        images = Array<UIImage?>(count: stories.count, repeatedValue: nil)
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.stories.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (indexPath.item < self.stories.count) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BookshelfCollectionViewCell
            
            // Configure the cell
            let story = self.stories[indexPath.item]
            
            if let image = images[indexPath.item] {
                cell.Cover.image = image
            } else
            {
                requestImage(story.icon, size: CGSizeMake(320, 320), synchronous: true, completion: { (image) -> () in
                    self.images[indexPath.item] = image;
                    cell.Cover.image = image ?? coverPhotoImageOrDefault(story.icon)
                })
            }
            
            
            return cell
        }
        else if (indexPath.item == self.stories.count) {
            return collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier2, forIndexPath: indexPath) as! AddCollectionViewCell
        }
        else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier3, forIndexPath: indexPath) as! CameraCollectionViewCell
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        if (indexPath.item < self.stories.count) {
            selectedIndex = indexPath.item
            let story = stories[selectedIndex]
            story.pages = App.database.getPages(story.id)!
        
            performSegueWithIdentifier("showStorybook", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "showStorybook":
            let viewer = segue.destinationViewController as! StoryViewerViewController
            viewer.story = self.stories[self.selectedIndex]
        default:
            break
        }
    }

}
