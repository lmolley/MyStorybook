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
let getThumbnailCommand = "http://10.5.5.9/gp/gpMediaMetadata?p="
let getMediaListCommand = "http://10.5.5.9:8080/gp/gpMediaList"
let getImageCommand = "http://10.5.5.9:8080/videos/DCIM/"
let deleteFileCommand = "http://10.5.5.9/gp/gpControl/command/storage/delete?p="

class CameraControlViewController : UIViewController {
    
    @IBOutlet weak var previewView: UIImageView!
    var isInSelfieMode:Bool = false
    let captureSession = AVCaptureSession()
    var cameraInputDevice:AVCaptureDeviceInput?
    let stillImageOutput = AVCaptureStillImageOutput()
    var selfiePreviewLayer:AVCaptureVideoPreviewLayer?
    
    @IBAction func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    var lastTakenPictureFilename:String? {
        didSet {
            HTTPImageGet(getThumbnailCommand + lastTakenPictureFilename!){(data:UIImage, error: String?) -> Void in
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
    
    var current_gopro_images = [String]()
    
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
        if self.isInSelfieMode {
            if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                    (imageDataSampleBuffer, error) -> Void in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                }
            }
        }
        else {
            HTTPGet(recordOnCommand){_,_ in}
            self.startGoProProcessing()
        }

        
    }
    
    @IBAction func toggleSelfie(sender: UIButton) {
        if !self.isInSelfieMode {
            if captureDevice != nil {
                beginFrontCameraSession()
                previewView.hidden = true
                self.isInSelfieMode = true
                sender.imageView!.image = UIImage(named:"camera_rear")
            }
        }
        else {
            if(selfiePreviewLayer != nil){
                selfiePreviewLayer!.removeFromSuperlayer()
            }
            previewView.image = UIImage(named:"default.jpg")
            captureSession.removeInput(cameraInputDevice)
            captureSession.stopRunning()
            previewView.hidden = false
            self.isInSelfieMode = false
            sender.imageView!.image = UIImage(named:"camera_front")
        }
    }
    
    private func beginFrontCameraSession() {
        do {
            if(cameraInputDevice == nil){
                try cameraInputDevice = AVCaptureDeviceInput(device: captureDevice)
            }
            captureSession.addInput(cameraInputDevice)
            selfiePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(selfiePreviewLayer!)
            selfiePreviewLayer!.frame = self.previewView.layer.frame
            updateOrientation()
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
 
    
    
    private func startGoProProcessing() -> Void {
//        self.current_gopro_images = [String]()
        HTTPGet(getMediaListCommand){
            (data: String, error: String?) -> Void in
            if error != nil {
                print(error)
            } else {
                //parse JSON returned from request to get out the filenames
                if let dataFromString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    for (_,library)in json["media"] {
                        let prefix:String = library["d"].string! + "/"
                        for (_, file) in library["fs"] {
                            let full_filename = prefix + file["n"].string!
                            if full_filename.containsString(".JPG") &&
                            !self.current_gopro_images.contains(full_filename){
                                self.current_gopro_images.append(full_filename)}
                        }
                        
                    }
                    print(self.current_gopro_images)
                    if(self.current_gopro_images.count != 0){
                        self.lastTakenPictureFilename = self.current_gopro_images.last
                    }
                    self.importGoProImages()
                }
                
            }
        }
    }
    
    private func importGoProImages() {
        if self.current_gopro_images.count != 0 {
            getImageFromGoProAndSave(self.current_gopro_images.first!)
        }
    }
    
    private func getImageFromGoProAndSave(path: String) -> Void {
        HTTPImageGet(getImageCommand + path){
            (data: UIImage, error: String?) -> Void in
            if error != nil {
                print(error)
            }
            else {
                UIImageWriteToSavedPhotosAlbum(data, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
    }

    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        guard error == nil else {
            print("error saving image")
            //Error saving image
            return
        }
        //Image saved successfully
        print("successful and deleting now...")
        HTTPGet(deleteFileCommand + self.current_gopro_images.first!){_,_ in
            self.current_gopro_images.removeFirst()
            self.startGoProProcessing()}
    }
   
    func updateOrientation() {
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
    
        switch (orientation)
        {
        case .Portrait:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            break
        case .LandscapeRight:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            break
        case .LandscapeLeft:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            break
        default:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            break
        }
        
    }
}

