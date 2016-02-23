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
    
    @IBAction func changeToCameraMode() {
        HTTPGet(cameraModeCommand){_,_ in }
    }
    @IBAction func changeToVideoMode() {
        HTTPGet(videoModeCommand){_,_ in }
    }
    @IBAction func record() {
        
        if(isRecording){
            HTTPGet(recordOffCommand){_,_ in }
        }
        else {
            HTTPGet(recordOnCommand){_,_ in }
        }
        
        isRecording = !isRecording
    }
    
}
