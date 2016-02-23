//
//  CoverPhotos.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

internal let AvailableCoverPhotos = getAvailableCoverPhotos()

internal func getAvailableCoverPhotos() -> [String]{
    let filemanager:NSFileManager = NSFileManager()
    let files = filemanager.enumeratorAtPath(NSHomeDirectory())
    while let file = files?.nextObject() {
        print(file)
    }
    return []
}

internal func randomCoverPhotoId() -> String
{
    return AvailableCoverPhotos[Int(arc4random()) % AvailableCoverPhotos.count]
}

internal func coverPhotoImageOrDefault(code: String) -> UIImage
{
    return UIImage(named: "CoverPhotos/\(code)") ?? UIImage(named: "file-folder-md")!
}