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
    var filterId: String?
    
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
        return 6
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
        default: break
        }
        
        let filter = CIFilter(name: filterName)
        filter?.setValue(origImage, forKey: kCIInputImageKey)
        if (indexPath.item == 1 || indexPath.item == 2) {
            filter?.setValue(0.5, forKey: kCIInputIntensityKey)
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
        switch(indexPath.item) {
        case 0: self.filterId = "CIPhotoEffectNoir"
        case 1: self.filterId = "CISepiaTone"
        case 2: self.filterId = "CIVignette"
        case 3: self.filterId = "CIColorInvert"
        case 4: self.filterId = "CIColorPosterize"
        case 5: self.filterId = "CIPhotoEffectTransfer"
        default: break
        }
        performSegueWithIdentifier("unwindFilter", sender: self)
    }
}
