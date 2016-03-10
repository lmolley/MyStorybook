//
//  PreStory.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import Photos

class PreStory{
    
    var moment: PHAssetCollection!
    var topImage: UIImage?
    var coverPhotoName: String?
    
    var image_ids = [String]()
    
    //add to these once you select the collection
    var images = [UIImage?]()
    var accepted_images = [UIImage]()
    var ordered_ids = [String]()
    //-------------------------------------------
    var title:String?
    var date:NSDate?
    var count:Int = 0
    
    init(title_in:String?, date_in:NSDate?) {
        title = title_in
        date = date_in
    }
    
    func addImageId(myAsset:PHAsset) {
        if count == 0 {
            setTopImage(myAsset)
        }
        image_ids.append(myAsset.localIdentifier)
        count += 1
    }
    
    private func setTopImage(myAsset:PHAsset) {
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        let imgManager = PHImageManager.defaultManager()
        imgManager.requestImageForAsset(myAsset, targetSize:CGSize(width: myAsset.pixelWidth, height: myAsset.pixelHeight), contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
            // Add the returned image to your array
            self.topImage = image
        })
    }
}