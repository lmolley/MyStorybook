//
//  EmailFavoritesViewController.swift
//  MyStorybook
//
//  Created by Quesada, David on 3/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import ContactsUI

class EmailFavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CNContactPickerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addFavorite() {
        let c = CNContactPickerViewController()
        
        c.delegate = self
        
        c.modalPresentationStyle = .CurrentContext
        
        self.presentViewController(c, animated: true, completion: nil)
    }

    func contactPickerDidCancel(picker: CNContactPickerViewController) {
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmailFavoriteCell", forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 17
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
}
