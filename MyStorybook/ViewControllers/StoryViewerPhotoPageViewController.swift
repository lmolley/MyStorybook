//
//  StoryViewerPhotoPageViewController.swift
//  MyStorybook
//
//  Created by David Paul Quesada on 3/10/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit
import Photos

// A view controller for one page of the album.
class StoryViewerPhotoPageViewController: UIViewController {
    internal var pageIndex: Int = 0
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    private var _image: UIImage! {
        willSet {
            
        }
        didSet {
            self.imageView?.image = _image
        }
    }
    
    internal var page: Page? {
        didSet {
            guard let page = page else {
                _image = nil
                return
            }
            
            let opts = PHFetchOptions()
            let result = PHAsset.fetchAssetsWithLocalIdentifiers([page.photoId], options: opts)
            
            if result.count == 0 {
                _image = nil
                return
            }
            
            let asset = result.objectAtIndex(0) as! PHAsset
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let opts2 = PHImageRequestOptions()
            opts2.synchronous = true
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFit, options: opts2) { (image, info) -> Void in
                self._image = image!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberLabel.text = "\(pageIndex + 1)"
        
        if self.imageView.image != self._image {
            self.imageView.image = self._image
        }
    }
}