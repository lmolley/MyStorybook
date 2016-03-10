//
//  CameraControlViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import AVFoundation

let recordOnCommand = "http://10.5.5.9/gp/gpControl/command/shutter?p=1"
let recordOffCommand = "http://10.5.5.9/gp/gpControl/command/shutter?p=0"
let cameraModeCommand = "http://10.5.5.9/gp/gpControl/command/mode?p=1"
let videoModeCommand = "http://10.5.5.9/gp/gpControl/command/mode?p=0"

class CameraControlViewController : UIViewController {
    
    @IBOutlet weak var previewView: UIImageView!
    var isInSelfieMode:Bool = false
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeToCameraMode()
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
    }
    
    func changeToCameraMode() {
        HTTPGet(cameraModeCommand){_,_ in }
    }

    @IBAction func record() {
        if isInSelfieMode {
            if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                    (imageDataSampleBuffer, error) -> Void in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                }
            }
        }
        else {
            HTTPGet(recordOnCommand){_,_ in }
            setPreviewImage()
        }
    }
    
    @IBAction func toggleSelfie(sender: UIButton) {
        if !isInSelfieMode {
            if captureDevice != nil {
                beginSession()
                previewView.hidden = true
                sender.setTitle("GoPro Mode", forState: .Normal)
                isInSelfieMode = true
            }
        }
        else {
//            captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice))
            captureSession.stopRunning()
            previewView.hidden = false
            sender.setTitle("Selfie Mode", forState: .Normal)
            isInSelfieMode = false
        }
        
        //toggle mode
        isInSelfieMode = !isInSelfieMode
    }
    
    private func beginSession() {
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer)
            previewLayer?.frame = self.previewView.layer.frame
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
        }
        catch _{
            print("issue adding input to capture session")
        }
        
        
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

