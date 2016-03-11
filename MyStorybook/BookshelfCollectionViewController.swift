//
//  BookshelfCollectionViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

private let reuseIdentifier = "BookCell"

class BookshelfCollectionViewController: UICollectionViewController {

    var selectedIndex = 0
    var stories = [Story]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        stories = App.database.getStories()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BookshelfCollectionViewCell
        
        // Configure the cell
        let story = self.stories[indexPath.item]
        cell.Cover.image = coverPhotoImageOrDefault(story.icon)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        selectedIndex = indexPath.item
        let story = stories[selectedIndex]
        story.pages = App.database.getPages(story.id)!
        
        performSegueWithIdentifier("showStorybook", sender: nil)
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
