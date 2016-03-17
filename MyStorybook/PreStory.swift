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
    var middleImage: UIImage?
    var bottomImage: UIImage?
    var coverPhotoName: String?
    
    var image_ids = [String]()
    
    //add to these once you select the collection
    var accepted_image_ids = [String]()
    //-------------------------------------------
    var title:String?
    var date:NSDate?
    var count:Int = 0
    
    init(title_in:String?, date_in:NSDate?) {
        title = title_in
        date = date_in
    }
}