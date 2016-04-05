//
//  EditFilterViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/18/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

private let filter_reuseIdentifier = "EditFilterCell"

class EditFilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var image: UIImage?
    var images: [UIImage?] = []
    
    @IBOutlet weak var editFilterCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editFilterCollection.dataSource = self
        editFilterCollection.delegate = self
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
        return 15
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filter_reuseIdentifier, forIndexPath: indexPath) as! EditFilterCollectionViewCell
        
        // Configure the cell
        
        let origImage = CIImage(image: image!)
        
        var filterName = ""
        switch (indexPath.item) {
        case 0: filterName = "CIPhotoEffectNoir"
        case 1: filterName = "CISepiaTone"
        case 2: filterName = "CIVignette"
        case 3: filterName = "CIColorInvert"
        case 4: filterName = "CIColorPosterize"
        case 5: filterName = "CIPhotoEffectTransfer"
        case 6: filterName = "CIColorMonochrome"
        case 7: filterName = "CIColorMonochrome"
        case 8: filterName = "CIColorMonochrome"
        case 9: filterName = "CIColorMonochrome"
        case 10: filterName = "CIColorMonochrome"
        case 11: filterName = "CIColorMonochrome"
        case 12: filterName = ""
        case 13: filterName = ""
        case 14: filterName = ""
        default: break
        }
        
        let filter = CIFilter(name: filterName)
        filter?.setValue(origImage, forKey: kCIInputImageKey)
        if (indexPath.item == 1 || indexPath.item == 2) {
            filter?.setValue(0.5, forKey: kCIInputIntensityKey)
        }
        if (indexPath.item == 6) {
            filter?.setValue(UIColor.redColor().CIColor, forKey: kCIInputColorKey)
        }
        if (indexPath.item == 7) {
            filter?.setValue(UIColor.orangeColor().CIColor, forKey: kCIInputColorKey)
        }
        if (indexPath.item == 8) {
            filter?.setValue(UIColor.yellowColor().CIColor, forKey: kCIInputColorKey)
        }
        if (indexPath.item == 9) {
            filter?.setValue(UIColor.redColor().CIColor, forKey: kCIInputColorKey)
        }
        if (indexPath.item == 10) {
            filter?.setValue(UIColor.redColor().CIColor, forKey: kCIInputColorKey)
        }
        if (indexPath.item == 1) {
            filter?.setValue(UIColor.redColor().CIColor, forKey: kCIInputColorKey)
        }
        let newImage = UIImage(CIImage: (filter?.outputImage)!)
        cell.filterImage.image = newImage
        images.append(newImage)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        self.image = images[indexPath.item]
        performSegueWithIdentifier("unwindFilter", sender: self)
    }
}
