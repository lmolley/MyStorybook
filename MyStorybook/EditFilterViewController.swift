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
    var editImage: UIImage?
    var filterId: String?
    
    @IBOutlet weak var editFilterCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(CGSizeMake(300, 300))
        self.image!.drawInRect(CGRectMake(0, 0, 300, 300))
        self.editImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        editFilterCollection.dataSource = self
        editFilterCollection.delegate = self
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filter_reuseIdentifier, forIndexPath: indexPath) as! EditFilterCollectionViewCell
        
        // Configure the cell
        
        let origImage = CIImage(image: self.editImage!)
        
        var filterName = ""
        switch (indexPath.item) {
        case 0: filterName = "CIPhotoEffectNoir"
        case 1: filterName = "CISepiaTone"
        case 2: filterName = "CIVignette"
        case 3: filterName = "CIColorInvert"
        case 4: filterName = "CIColorPosterize"
        case 5: filterName = "CIPhotoEffectTransfer"
        default: break
        }
        
        let filter = CIFilter(name: filterName)
        filter?.setValue(origImage, forKey: kCIInputImageKey)
        if (indexPath.item == 1 || indexPath.item == 2) {
            filter?.setValue(0.5, forKey: kCIInputIntensityKey)
        }
        let newImage = UIImage(CIImage: (filter?.outputImage)!)
        cell.filterImage.image = newImage
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        let origImage = CIImage(image: self.image!)
        
        switch(indexPath.item) {
        case 0: self.filterId = "CIPhotoEffectNoir"
        case 1: self.filterId = "CISepiaTone"
        case 2: self.filterId = "CIVignette"
        case 3: self.filterId = "CIColorInvert"
        case 4: self.filterId = "CIColorPosterize"
        case 5: self.filterId = "CIPhotoEffectTransfer"
        default: break
        }
        let filter = CIFilter(name: self.filterId!)
        filter?.setValue(origImage, forKey: kCIInputImageKey)
        if (indexPath.item == 1 || indexPath.item == 2) {
            filter?.setValue(0.5, forKey: kCIInputIntensityKey)
        }
        self.image = UIImage(CGImage: CIContext(options:nil).createCGImage(filter!.outputImage!, fromRect:filter!.outputImage!.extent))
        
        performSegueWithIdentifier("unwindFilter", sender: self)
    }
}
