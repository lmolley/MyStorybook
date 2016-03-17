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
    var story: Story?
    var page: Page?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return story?.pages?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(edit_reuseIdentifier, forIndexPath: indexPath) as! EditCollectionViewCell
            
        // Configure the cell
        let page_cell = self.story!.pages![indexPath.item]
        
        cell.EditImage.image = UIImage(named: "default.jpg")
        cell.EditPageNum.text = "\(page_cell.number)"
            
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
            cell?.layer.borderWidth = 1.0
            cell?.layer.borderColor = UIColor.greenColor().CGColor
   
        page = story?.pages?[indexPath.item]
        tap = true
        //performSegueWithIdentifier("editCollectionReturnSegue", sender: page)
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        cell?.layer.borderWidth = 0.0
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "")
        {
        case "editCollectionReturnSegue":
            let viewer = segue.destinationViewController as! EditContainerViewController
            viewer.page = self.page
        default:
            break
        }*/

}
