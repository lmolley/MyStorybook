//
//  EditEmojiViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/18/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

private let emoji_reuseIdentifier = "EditEmojiCell"

class EditEmojiViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var text: String?
    
    var emojiList = ["😀","😍","😎","😕","😛","😡"]
    
    @IBOutlet weak var editEmojiCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editEmojiCollection.dataSource = self
        editEmojiCollection.delegate = self
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
    
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(emoji_reuseIdentifier, forIndexPath: indexPath) as! EditEmojiCollectionViewCell
        
        // Configure the cell
        cell.emojiLabel.text = emojiList[indexPath.item]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        self.text = self.emojiList[indexPath.item]
        performSegueWithIdentifier("unwindEmoji", sender: self)
    }
}
