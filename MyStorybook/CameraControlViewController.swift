//
//  CameraControlViewController.swift
//  MyStorybook
//
//  Created by Lauren Molley on 2/22/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import UIKit
import AVFoundation

let cameraShutterSound:SystemSoundID = 1108
let recordOnCommand = "http://10.5.5.9/gp/gpControl/command/shutter?p=1"
let recordOffCommand = "http://10.5.5.9/gp/gpControl/command/shutter?p=0"
let cameraModeCommand = "http://10.5.5.9/gp/gpControl/command/mode?p=1"
let videoModeCommand = "http://10.5.5.9/gp/gpControl/command/mode?p=0"
let getThumbnailCommand = "http://10.5.5.9/gp/gpMediaMetadata?p="
let getMediaListCommand = "http://10.5.5.9:8080/gp/gpMediaList"
let getImageCommand = "http://10.5.5.9:8080/videos/DCIM/"
let deleteFileCommand = "http://10.5.5.9/gp/gpControl/command/storage/delete?p="

class CameraControlViewController : UIViewController {
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var spinningCircle: UIActivityIndicatorView!
    @IBOutlet weak var previewView: UIImageView!
    var isInSelfieMode:Bool = false
    let captureSession = AVCaptureSession()
    var cameraInputDevice:AVCaptureDeviceInput?
    let stillImageOutput = AVCaptureStillImageOutput()
    var selfiePreviewLayer:AVCaptureVideoPreviewLayer?
    var currentPhotoBeingSaved:String? = nil
    
    @IBAction func goHome(sender: UIButton) {
        //if no photos to save then just go home
        if current_gopro_images.count == 0 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        //otherwise show alert to ask if they would like to save
        else {
            let save_alert = UIAlertController(title: "GoPro Photos", message: "Would you like to save your photos from the GoPro to the device?", preferredStyle: UIAlertControllerStyle.Alert)
            
            save_alert.addAction(UIAlertAction(
                title: "Save Photos",
            style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                self.savePhotos()
                self.navigationController?.popToRootViewControllerAnimated(true)
                })
            
            save_alert.addAction(UIAlertAction(
                title: "Don't Save Photos",
            style: UIAlertActionStyle.Destructive) { (action:UIAlertAction) -> Void in
                self.navigationController?.popToRootViewControllerAnimated(true)
                })
            
            save_alert.addAction(UIAlertAction(
                title: "Cancel",
            style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
                })
            save_alert.modalPresentationStyle = .Popover
            let ppc = save_alert.popoverPresentationController
            ppc?.sourceView = sender
            ppc?.sourceRect = sender.bounds
            presentViewController(save_alert, animated:true, completion:nil)
        }
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
        
        //GoPro set up
        changeToCameraMode()
        self.startGoProProcessing(false)
        
        
        //Selfie set up
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
        
//        let timer = NSTimer(timeInterval: 5.0, target: self, selector: "saveAnyPhotos", userInfo: nil, repeats: true)
//        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
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
            AudioServicesPlaySystemSound(cameraShutterSound);
            previewView.hidden = true
            spinningCircle.startAnimating()
            spinningCircle.hidden = false
            //disable shutter button until we have added the photo
            shutterButton.enabled = false
            //this is going to call go pro processing 
            //until a new picture is added to the array
            print("before timer")
            let timer = NSTimer(timeInterval: 2, target: self, selector: #selector(CameraControlViewController.startProcessingWithDelay), userInfo: nil, repeats: false)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }

        
    }
    
    @IBAction func toggleSelfie(sender: UIButton) {
        if !self.isInSelfieMode {
            if captureDevice != nil {
                beginFrontCameraSession()
                previewView.hidden = true
                self.isInSelfieMode = true
//                sender.imageView!.image = UIImage(named:"camera_rear")
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
            changeToCameraMode()
//            sender.imageView!.image = UIImage(named:"camera_front")
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
 
    func startProcessingWithDelay()->Void {
        print("about to process")
        startGoProProcessing(true)
        self.spinningCircle.stopAnimating()
        self.spinningCircle.hidden = true

    }
    
    func startGoProProcessing(cameFromShutter:Bool) -> Void {
        HTTPGet(getMediaListCommand){
            (data: String, error: String?) -> Void in
            if error != nil {
                print(error)
            } else {
                var madeAnUpdate = false
                //parse JSON returned from request to get out the filenames
                if let dataFromString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    for (_,library)in json["media"] {
                        let prefix:String = library["d"].string! + "/"
                        for (_, file) in library["fs"] {
                            let full_filename = prefix + file["n"].string!
                            if full_filename.containsString(".JPG") &&
                            !self.current_gopro_images.contains(full_filename){
                                if self.currentPhotoBeingSaved != nil {
                                    if full_filename != self.currentPhotoBeingSaved! {
                                        madeAnUpdate = true
                                        self.current_gopro_images.append(full_filename)
                                    }
                                }
                                else {
                                    madeAnUpdate = true
                                    self.current_gopro_images.append(full_filename)
                                }
                            }
                        }
                        
                    }
                    print(self.current_gopro_images)
                    if(self.current_gopro_images.count != 0){
                        self.lastTakenPictureFilename = self.current_gopro_images.last
                    }
                    
                    //if this came from a shutter command
                    //we know we should've added a photo
                    //so keep trying
                    if cameFromShutter && !madeAnUpdate {
                        self.startGoProProcessing(true)
                    }
                    //reenable the shutter button now because we are finished
                    else {
                        print("hit this")
                    self.previewView.hidden = false
                    self.shutterButton.enabled = true
                    return
                    }
                }
                
            }
        }
    }
    
    func savePhotos(){
        //check if we don't have any photos to save
        if current_gopro_images.count == 0 {
            return;
        }
        if let first_image = current_gopro_images.first {
            currentPhotoBeingSaved = first_image
            current_gopro_images.removeFirst()
            getImageFromGoProAndSave(currentPhotoBeingSaved!)
        }
        else {
            print("error getting first image")
            return;
        }
    }
    
    private func getImageFromGoProAndSave(path: String) -> Void {
        HTTPImageGet(getImageCommand + path){
            (data: UIImage, error: String?) -> Void in
            if error != nil {
                print(error)
            }
            else {
                UIImageWriteToSavedPhotosAlbum(data.resize(0.5), self, #selector(CameraControlViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }

    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        guard error == nil else {
            print("error saving image")
            //Error saving image
            savePhotos()
            return
        }
        //Image saved successfully
        print("successful save and deleting now...")
        HTTPGet(deleteFileCommand + self.currentPhotoBeingSaved!){_,_ in
            print("successful deletion!")
            self.savePhotos()
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateOrientation()
    }
   
    func updateOrientation() {
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
    
        switch (orientation)
        {
        case .LandscapeRight:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
//            print(previewView.image!.imageOrientation)
            break
        case .LandscapeLeft:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
//            print(previewView.image!.imageOrientation)
            break
        default:
            selfiePreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
//            print(previewView.image!.imageOrientation)
            break
        }
        
    }
}

extension UIImage {
    func resize(scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
}
}


