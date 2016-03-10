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
let deleteFileCommand = "http://10.5.5.9/gp/gpControl/command/storage/delete?p="
let albumName = "GOPRO"

class GoProImagesViewController : UICollectionViewController {
    
    var preStories = [PreStory]()
    var image_count:Int = 0
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    var maxImageCount:Int!
    var gopro_images:[String] = [String]()
    var gopro_folder:PreStory = PreStory(title_in: "GOPRO", date_in: NSDate())

    override func viewDidLoad() {
        super.viewDidLoad()
        preStories.append(gopro_folder)
        fetchMomentsFromCameraRoll()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            self.makeGoProAlbum()
            self.startGoProProcessing()
            dispatch_async(dispatch_get_main_queue()) {
            }
        }
    }
    
    private func makeGoProAlbum(){
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.gopro_folder.moment = first_Obj as! PHAssetCollection
        }else{
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                },
                completionHandler: {(success:Bool, error:NSError?)in
                    if(success){
                        print("Successfully created folder")
                        let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                        self.gopro_folder.moment = collection.firstObject as! PHAssetCollection
                    }else{
                        print("Error creating folder")
                    }
            })
        }
    }
    
    private func startGoProProcessing() -> Void {
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
            self.importGoProImages()
        }
    }
    
    private func importGoProImages() {
        var count = 0
        for image_file in self.gopro_images {
            if(image_file.containsString(".JPG")) {
                getImageFromGoProAndSave(image_file)
                if(count == 0){
                    self.fetchFirstPhotoInMoment(0)
                }
                count++
            }

        }
    }
    
    private func getImageFromGoProAndSave(path: String) -> Void {
        HTTPImageGet(getImageCommand + path){
            (data: UIImage, error: String?) -> Void in
            if error != nil {
                print(error)
            }
            else {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(data)
                    let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.gopro_folder.moment)
                    let enumeration: NSArray = [assetPlaceholder!]
                    albumChangeRequest!.addAssets(enumeration)
                    }, completionHandler: {(success:Bool, error:NSError?)in
                        if(success){
                            print("Successfully Saved Photo")
                            print("deleting photo now...")
                            HTTPGet(deleteFileCommand + path){_,_ in }
                        }else{
                            print("Saving photo")
                        }
                })
            
            }
        }
    }
    
    private func fetchMomentsFromCameraRoll () {
        print("about to fetch!")
        maxImageCount = 50
        
        let collectionFetchOptions = PHFetchOptions()
        collectionFetchOptions.sortDescriptors = [NSSortDescriptor(key:"startDate", ascending: false)]
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Moment, subtype: .Any, options: collectionFetchOptions)
        
        smartAlbums.enumerateObjectsUsingBlock({
            
            if let collection = $0.0 as? PHAssetCollection {
                
                let new_folder = PreStory(title_in: collection.localizedTitle, date_in: collection.startDate)
                
                new_folder.moment = collection
                
                // Begin attempt to get the top image. If there is none, don't bother with the moment. (Would there ever be a moment without an image?)
                self.preStories.append(new_folder)
                self.fetchFirstPhotoInMoment(self.preStories.count-1)
            }
        })
    }
    
    // Returns true if the moment has at least one photo
    private func fetchFirstPhotoInMoment(folder_index:Int)-> Bool
    {
        let folder = self.preStories[folder_index]
        let opts = PHFetchOptions()
        opts.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        opts.fetchLimit = 1
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(folder.moment, options: opts)
        
        if fetchResult.count == 0 {
            return false
        }
        
        let indexPath = NSIndexPath(forItem: folder_index, inSection: 0)
        
        let asset = fetchResult.objectAtIndex(0) as! PHAsset
        let imageOptions = PHImageRequestOptions()
        imageOptions.synchronous = false

        let size = CGSizeMake(200, 200)
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFit, options: imageOptions) { (image, info) -> Void in
            
            if image != nil {
                folder.topImage = image
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
        
        return true
    }
    

    
//********OVERRIDES FOR COLLECTION VIEW TO WORK***************
    override func numberOfSectionsInCollectionView(collectionView:
        UICollectionView) -> Int {
            //only one section so we just return 1
            return 1
    }
    
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            //return number of images in our 1 section
            return preStories.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoPro_reuseIdentifier,forIndexPath: indexPath) as! GoProImageCollectionViewCell
        let story = preStories[indexPath.row]
            
        // Configure the cell
        cell.titleLabel.text = story.title
        cell.dateLabel.text = getDate(story.date!)
        
        if (preStories.count > indexPath.row && (story.topImage != nil)) {
            cell.imageView.image = story.topImage
            cell.spinningCircle.stopAnimating()
        }
        else {
            cell.imageView.image = UIImage(named: "default.jpg")
            cell.spinningCircle.startAnimating()
        }
        
        // TODO: FIXME: For some reason, the text labels in the cells randomly fail to appear sometimes.
        cell.setNeedsLayout()
        cell.setNeedsUpdateConstraints()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let story = preStories[indexPath.row]
        let result = PHAsset.fetchAssetsInAssetCollection(story.moment, options: nil)
        
        // TODO: Check if the story already has its images?
        // TODO: Optimize this part of the app more. Maybe we don't entirely need to grab all of the images.
        
        var assetIDs = [String](count: result.count, repeatedValue: "")
        var images = [UIImage?](count: result.count, repeatedValue: nil)
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .HighQualityFormat
        imageOptions.synchronous = true
        
        result.enumerateObjectsWithOptions(NSEnumerationOptions.Concurrent, usingBlock: { (obj, index, _) -> Void in
                
            let asset = obj as! PHAsset
            assetIDs[index] = asset.localIdentifier
                
                var size = CGSize()
                size.width = CGFloat(asset.pixelWidth)
                size.height = CGFloat(asset.pixelHeight)
                PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFit, options: imageOptions, resultHandler: { (image, _) -> Void in
                    images[index] = image
                })
        })
        
        story.image_ids = assetIDs
        story.images = images;
        
        performSegueWithIdentifier("PhotoSelectorSegue", sender: story)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoSelectorSegue"
        {
            if let destinationVC = segue.destinationViewController as? PhotoSelectorViewController{
                if let folder = sender as? PreStory {
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