//
//  GoProImagesViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit
import Photos

let GoPro_reuseIdentifier = "GoProImageCell"
let getThumbnailCommand = "http://10.5.5.9/gp/gpMediaMetadata?p="
let getMediaListCommand = "http://10.5.5.9:8080/gp/gpMediaList"
let getImageCommand = "http://10.5.5.9:8080/videos/DCIM/"

class GoProImagesViewController : UICollectionViewController {
    
    var camera_roll_images:NSMutableArray! // <-- Array to hold the fetched images
    var folders:[MyMomentCollection] = [MyMomentCollection]()
    var image_count:Int = 0
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    var maxImageCount:Int!
    var gopro_images:[String] = [String]()
    var gopro_folder:MyMomentCollection = MyMomentCollection(title_in: "GOPRO", date_in: NSDate())

    override func viewDidLoad() {
        super.viewDidLoad()
        folders.append(gopro_folder)
        fetchPhotosFromCameraRoll()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            self.getGoProImages()
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView!.reloadData()
            }
        }
    }
    
    private func getGoProImages() -> Void {
        HTTPGet(getMediaListCommand){
            (data: String, error: String?) -> Void in
            if error != nil {
                print(error)
            } else {
                //parse JSON returned from request to get out the filenames
                if let dataFromString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    for (_,library)in json["media"] {
                        let prefix:String = library["d"].string! + "/"
                        for (_, file) in library["fs"] {
                            self.gopro_images.append(prefix + file["n"].string!)
                        }
                        
                    }
                }
            }
            print(self.gopro_images)
            self.saveImages()
        }
    }
    
    private func saveImages() {
        for image_file in self.gopro_images {
            if(image_file.containsString(".JPG")) {
                getAndSaveImage(image_file)
            }
        }
        
    }
    
    private func getAndSaveImage(path: String) -> Void {
        HTTPImageGet(getImageCommand + path){
            (data: UIImage, error: String?) -> Void in
            if error != nil {
                print(error)
            }
            else {
                self.gopro_folder.addImage(data)
                print("saving data")
                UIImageWriteToSavedPhotosAlbum(data, nil, nil, nil)
            }
        }
    }
    
    private func fetchPhotosFromCameraRoll () {
        print("about to fetch!")
        maxImageCount = 50
        let collections = fetchCollections()
        camera_roll_images = NSMutableArray(capacity:collections.count)
        self.getImagesFromCollectionResult(collections)
        
    }
    
    private func fetchCollections() -> PHFetchResult{
        let collectionFetchOptions = PHFetchOptions()
        collectionFetchOptions.sortDescriptors = [NSSortDescriptor(key:"startDate", ascending: false)]
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Moment, subtype: .Any, options: collectionFetchOptions)
        return smartAlbums

        
    }
    private func getImagesFromCollectionResult(result:PHFetchResult) {
        result.enumerateObjectsUsingBlock({
            print("starting block")
            if let collection = $0.0 as? PHAssetCollection {
                if self.camera_roll_images.count < self.maxImageCount {
                    let new_folder = MyMomentCollection(title_in: collection.localizedTitle, date_in: collection.startDate)
                    self.folders.append(new_folder)
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                        self.fetchPhotoAtIndexFromEnd(0, assetCol: collection, folder: new_folder)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.reloadData()
                        }
                    }
                }

            }
            
        })
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    private func fetchPhotoAtIndexFromEnd(index:Int, assetCol:PHAssetCollection, folder:MyMomentCollection) {
        
        let imgManager = PHImageManager.defaultManager()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCol, options: fetchOptions) {
            
            // If the fetch result isn't empty,
            // proceed with the image request
            if fetchResult.count > 0 {
                // Perform the image request
                imgManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    // Add the returned image to your array
//                    self.camera_roll_images.addObject(image!)
                    folder.addImage(image!)
                    self.image_count += 1
                    
                    // If you haven't already reached the first
                    // index of the fetch result and if you haven't
                    // already stored all of the images you need,
                    // perform the fetch request again with an
                    // incremented index
                    if index + 1 < fetchResult.count && self.image_count < self.maxImageCount {
                        self.fetchPhotoAtIndexFromEnd(index + 1, assetCol: assetCol, folder: folder)
                    }
                })
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
//            return camera_roll_images.count
//            return image_count
            return folders.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoPro_reuseIdentifier,forIndexPath: indexPath) as! GoProImageCollectionViewCell
            
            // Configure the cell
        if folders.count > indexPath.row && folders[indexPath.row].images.count > 0 {
            cell.imageView.image = folders[indexPath.row].images[0]
            cell.titleLabel.text = folders[indexPath.row].title
            cell.dateLabel.text = getDate(folders[indexPath.row].date!)
            cell.spinningCircle.stopAnimating()
        }
        else {
            cell.imageView.image = UIImage(named: "default.jpg")
            cell.spinningCircle.startAnimating()
        }
            return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("PhotoSelectorSegue", sender: folders[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoSelectorSegue"
        {
            if let destinationVC = segue.destinationViewController as? PhotoSelectorViewController{
                if let folder = sender as? MyMomentCollection {
                    destinationVC.titleToDisplay = folder.title
                    destinationVC.folderToDisplay = folder
                }
            }
        }
    }
    private func getDate(date:NSDate)->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.stringFromDate(date)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header: GoProImagesHeaderViewController?
        
        if kind == UICollectionElementKindSectionHeader {
            header =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "SelectImageHeader", forIndexPath: indexPath)
                as? GoProImagesHeaderViewController
            
            header?.headerLabel.text = "Select Image Folder"
        }
        return header!
    }
    
}