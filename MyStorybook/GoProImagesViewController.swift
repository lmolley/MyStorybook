//
//  GoProImagesViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

let GoPro_reuseIdentifier = "GoProImageCell"
let getThumbnailCommand = "http://10.5.5.9/gp/gpMediaMetadata?p="
let getMediaListCommand = "http://10.5.5.9:8080/gp/gpMediaList"

class GoProImagesViewController : UICollectionViewController {
    
    var images = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //TODO: Get list of GoPro images from the camera here
        //hardcoded for now
        images = [
            "/100GOPRO/GOPR0008.JPG",
            "/100GOPRO/GOPR0009.JPG",
            "/100GOPRO/GOPR0010.JPG"]
        
    }
    
    private func getImage(path: String, cell:GoProImageCollectionViewCell) -> Void {
        print("attempting to get thumbnail for \(path)")
        HTTPImageGet(getThumbnailCommand + path){
            (data: UIImage, error: String?) -> Void in
            if error != nil {
                print(error)
            }
            else {
                print("setting data")
                cell.imageView.image = data
            }
        }
    }

//********OVERRIDES FOR COLLECTION VIEW TO WORK***************
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView!) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    override func collectionView(collectionView: UICollectionView!,
        numberOfItemsInSection section: Int) -> Int {
            //return number of images in our 1 section
            return images.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoPro_reuseIdentifier,forIndexPath: indexPath) as! GoProImageCollectionViewCell
            
            // Configure the cell
            getImage(images[indexPath.row], cell: cell)
            return cell
    }
    
}