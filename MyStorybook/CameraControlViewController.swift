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
    
    var isRecording:Bool = false
    var isVideoMode:Bool = false
    var isCameraMode:Bool = false
    
    @IBAction func changeToCameraMode() {
        HTTPGet(cameraModeCommand){_,_ in }
        
        isVideoMode = false
        isCameraMode = true
        
        cameraButton.layer.borderColor = UIColor.blackColor().CGColor
        cameraButton.layer.borderWidth = 1
        videoButton.layer.borderWidth = 0
        recordButton.layer.borderWidth = 0
    }
    @IBAction func changeToVideoMode() {
        HTTPGet(videoModeCommand){_,_ in }
        
        isVideoMode = true
        isCameraMode = false
        
        videoButton.layer.borderColor = UIColor.blackColor().CGColor
        videoButton.layer.borderWidth = 1
        cameraButton.layer.borderWidth = 0
    }
    @IBAction func record() {
        
        if(isRecording){
            HTTPGet(recordOffCommand){_,_ in }
            
            recordButton.layer.borderWidth = 0
        }
        else {
            HTTPGet(recordOnCommand){_,_ in }
            
            if(isVideoMode){
                recordButton.layer.borderColor = UIColor.redColor().CGColor
                recordButton.layer.borderWidth = 1
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
    
}
