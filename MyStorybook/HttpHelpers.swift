//
//  HttpHelpers.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/21/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

func HTTPsendRequest(request: NSMutableURLRequest,callback: (String, String?) -> Void) {
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request,completionHandler :
        {
            data, response, error in
            if error != nil {
                callback("", (error!.localizedDescription) as String)
            } else {
                callback(NSString(data: data!, encoding: NSUTF8StringEncoding) as! String,nil)
            }
    })
    
    task.resume() //Tasks are called with .resume()
    
}

func HTTPGet(url: String, callback: (String, String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: url)!) //To get the URL of the receiver , var URL: NSURL? is used
    HTTPsendRequest(request, callback: callback)
}

func HTTPsendImageRequest(request: NSMutableURLRequest,callback: (UIImage, String?) -> Void) {
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request,completionHandler :
        {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error != nil {
                    callback(UIImage(), (error!.localizedDescription) as String)
                }
                else{
                    callback(UIImage(data: data!)!,nil)
                }
            })
    })
    
    task.resume() //Tasks are called with .resume()
}
func HTTPImageGet(url: String, callback: (UIImage, String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: url)!) //To get the URL of the receiver , var URL: NSURL? is used
    HTTPsendImageRequest(request, callback: callback)
}
