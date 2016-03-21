//
//  EmailFavoritesViewController.swift
//  MyStorybook
//
//  Created by Quesada, David on 3/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts

class EmailFavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CNContactPickerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!;
    
    var ids: [String]!
    var contacts: [CNContact]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        load()
    }
    
    private func load()
    {
        ids = EmailFavorites.getContactIdentifiers() ?? []
        contacts = []
        
        if ids.count == 0 {
            collectionView.reloadData()
            return
        }
        
        let store = CNContactStore()
        let request = CNContactFetchRequest(keysToFetch: [CNContactEmailAddressesKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey])
        
        let predicate = CNContact.predicateForContactsWithIdentifiers(ids)
        
        contacts = (try? store.unifiedContactsMatchingPredicate(predicate, keysToFetch: request.keysToFetch)) ?? []
        
        collectionView.reloadData()
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
        print(contact)
        
        var list = EmailFavorites.getContactIdentifiers() ?? []
        list.append(contact.identifier)
        EmailFavorites.setContactIdentifiers(list)
        
        load()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmailFavoriteCell", forIndexPath: indexPath) as! EmailFavoriteCollectionViewCell
        
        let contact = contacts[indexPath.item]
        
        
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        cell.emailLabel.text = contact.emailAddresses[0].value as? String
        
        if let imageData = contact.imageData {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.dismiss()
    }
}

class EmailFavorites
{
    private static let userDefaultsKey = "FavoriteEmailContacts"
    
    static func getContactIdentifiers() -> [String]? {
        return NSUserDefaults.standardUserDefaults().valueForKey(userDefaultsKey) as? [String]
    }
    
    static func setContactIdentifiers(ids: [String]) {
        NSUserDefaults.standardUserDefaults().setValue(ids, forKey: userDefaultsKey)
    }
}
