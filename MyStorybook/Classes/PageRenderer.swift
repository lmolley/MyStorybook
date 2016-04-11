//
//  PageRenderer.swift
//  MyStorybook
//
//  Created by Quesada, David on 4/11/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit

class PageRenderer {

    internal func render(page page: Page, onImage image: UIImage) -> UIImage
    {
        // Disabled until/unless I feel like getting this all to work nicely. (Images with filters appear slightly stretched. Plus it takes a while to do a filter on the large images. We might need to cache them).
//        var image = image
//        
//        if (page.filterId != "")
//        {
//            image = _renderFilter(page, image: image)
//        }
        
        return image
    }
    
    private func _renderFilter(page: Page, image: UIImage) -> UIImage
    {
        let filterName = page.filterId
        guard let filter = CIFilter(name: filterName) else {
            fatalError("Can't make filter with id \(filterName)")
        }
        
        filter.setValue(image.CIImage ?? CIImage(image: image), forKey: kCIInputImageKey)
        if (filterName == "CISepiaTone" || filterName == "CIVignette") {
            filter.setValue(0.5, forKey: kCIInputIntensityKey)
        }
        return UIImage(CIImage: filter.outputImage!)
    }
    
}
