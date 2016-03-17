//
//  EditCollectionViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/14/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

private let edit_reuseIdentifier = "EditCell"

class EditCollectionViewController: UICollectionViewController {
    var selectedIndex = 0
    internal var story: Story?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return story!.pages!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(edit_reuseIdentifier, forIndexPath: indexPath) as! EditCollectionViewCell
            
        // Configure the cell
        let page = self.story!.pages![indexPath.item]
        
        cell.EditImage.image = UIImage(named: "default.jpg")
        cell.EditPageNum.text = "\(page.number)"
            
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
