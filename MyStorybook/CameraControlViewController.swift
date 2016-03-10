//
//  CameraControlViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
let recordOnCommand = "http://10.5.5.9/gp/gpControl/command/shutter?p=1"
let recordOffCommand = "http://10.5.5.9/gp/gpControl/command/shutter?p=0"
let cameraModeCommand = "http://10.5.5.9/gp/gpControl/command/mode?p=1"
let videoModeCommand = "http://10.5.5.9/gp/gpControl/command/mode?p=0"

class CameraControlViewController : UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var previewView: UIImageView!
    
    var isRecording:Bool = false
    var isVideoMode:Bool = false
    var isCameraMode:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeToCameraMode()
    }
    
    @IBAction func changeToCameraMode() {
        HTTPGet(cameraModeCommand){_,_ in }
        
        isVideoMode = false
        isCameraMode = true
        
        cameraButton.layer.borderColor = UIColor.blackColor().CGColor
        cameraButton.layer.borderWidth = 3
        videoButton.layer.borderWidth = 0
        recordButton.layer.borderWidth = 0
    }
    @IBAction func changeToVideoMode() {
        HTTPGet(videoModeCommand){_,_ in }
        
        isVideoMode = true
        isCameraMode = false
        
        videoButton.layer.borderColor = UIColor.blackColor().CGColor
        videoButton.layer.borderWidth = 3
        cameraButton.layer.borderWidth = 0
    }
    @IBAction func record() {
        
        if(isRecording){
            HTTPGet(recordOffCommand){_,_ in }
            
            recordButton.layer.borderWidth = 0
        }
        else {
            HTTPGet(recordOnCommand){_,_ in }
            setPreviewImage()
            
            if(isVideoMode){
                recordButton.layer.borderColor = UIColor.redColor().CGColor
                recordButton.layer.borderWidth = 3
            }
            
        }
        
        if(isCameraMode){
            isRecording = false
        }
        else{
            isRecording = !isRecording
        }
        
        //isRecording = !isRecording
    }
 
    private func setPreviewImage(){
        var imageList = [String]()
        HTTPGet(getMediaListCommand){
            (data: String, error: String?) -> Void in
            if error != nil {
                print(error)
                return;
            } else {
                //parse JSON returned from request to get out the filenames
                if let dataFromString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    for (_,library)in json["media"] {
                        let prefix:String = library["d"].string! + "/"
                        for (_, file) in library["fs"] {
                            let name = file["n"].string!
                            if name.containsString(".JPG") {
                                imageList.append(prefix + name)}
                        }
                        
                    }
                }
                
                if imageList.count == 0 {
                    return;
                }
                
                let filename = imageList.last
                HTTPImageGet(getThumbnailCommand + filename!){(data:UIImage, error: String?) -> Void in
                    if error != nil {
                        print(error)
                        return;
                    }
                    else{
                        self.previewView.image = data
                    }
                    
                }
            }
        }
    }
}

