//
//  EditFrameViewController.swift
//  MyStorybook
//
//  Created by Rachel Choi on 3/18/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

private let frame_reuseIdentifier = "EditFrameCell"

class EditFrameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var image: UIImage?
    var images: [UIImage?] = []
    
    @IBOutlet weak var editFrameCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editFrameCollection.dataSource = self
        editFrameCollection.delegate = self
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(frame_reuseIdentifier, forIndexPath: indexPath) as! EditFrameCollectionViewCell
        
        // Configure the cell
        
        var newImage = self.image
        UIGraphicsBeginImageContextWithOptions((newImage?.size)!, false, 0)
        
        let rect = CGRectMake(0, 0, newImage!.size.width, newImage!.size.height)
        let borderWidth: CGFloat = 10.0
        let borderHalf: CGFloat = 5.0
        let path = UIBezierPath(rect: CGRectInset(rect, borderHalf, borderHalf))
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        path.addClip()
        
        newImage!.drawInRect(rect)
        CGContextStrokeRect(context, rect)
        
        switch (indexPath.item) {
        case 0: UIColor.redColor().setStroke()
        case 1: UIColor.orangeColor().setStroke()
        case 2: UIColor.yellowColor().setStroke()
        case 3: UIColor.greenColor().setStroke()
        case 4: UIColor.blueColor().setStroke()
        case 5: UIColor.purpleColor().setStroke()
        default: break
        }
        
        path.lineWidth = borderWidth
        path.stroke()
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        images.append(newImage)
        cell.frameImage.image = newImage
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        self.image = images[indexPath.item]
        performSegueWithIdentifier("unwindFrame", sender: self)
    }
}
