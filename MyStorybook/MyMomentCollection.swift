//
//  MyMomentCollection.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import Photos

class MyMomentCollection{

    var images = [UIImage]()
    var accepted_images = [UIImage]()
    var title:String?
    var date:NSDate?
    var count:Int = 0
    
    init(title_in:String?, date_in:NSDate?) {
        title = title_in
        date = date_in
    }
    
    func addImage(new_image: UIImage) {
        images.append(new_image)
        count += 1
    }
}