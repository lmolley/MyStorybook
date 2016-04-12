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
    
    @IBOutlet weak var previewView: UIImageView!
    var isInSelfieMode:Bool = false
    let captureSession = AVCaptureSession()
    var cameraInputDevice:AVCaptureDeviceInput?
    let stillImageOutput = AVCaptureStillImageOutput()
    var selfiePreviewLayer:AVCaptureVideoPreviewLayer?
    var currentPhotoBeingSaved:String? = nil
    
    
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
        
        let timer = NSTimer(timeInterval: 5.0, target: self, selector: "saveAnyPhotos", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
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
            //disable shutter button until we have added the photo
            shutterButton.enabled = false
            //this is going to call go pro processing 
            //until a new picture is added to the array
            self.startGoProProcessing(true)
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
                        
//                        self.startGoProProcessing(true)
                        let timer = NSTimer(timeInterval: 1, target: self, selector: "startGoProProcessing", userInfo: nil, repeats: false)
                        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                    }
                    //reenable the shutter button now because we are finished
                    self.shutterButton.enabled = true
                    return
                }
                
            }
        }
    }
    
    func saveAnyPhotos(){
        //check if we're in the middle of saving a photo
        if currentPhotoBeingSaved != nil {
            return;
        }
        //check if we don't have any photos to save
        if current_gopro_images.count == 0 {
            return;
        }
        currentPhotoBeingSaved = current_gopro_images.first!
        current_gopro_images.removeFirst()
        getImageFromGoProAndSave(currentPhotoBeingSaved!)
    }
    
    private func getImageFromGoProAndSave(path: String) -> Void {
        HTTPImageGet(getImageCommand + path){
            (data: UIImage, error: String?) -> Void in
            if error != nil {
                print(error)
            }
            else {
                UIImageWriteToSavedPhotosAlbum(data.resize(0.5), self, "image:didFinishSavingWithError:contextInfo:", nil)
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
        print("successful save and deleting now...")
        HTTPGet(deleteFileCommand + self.currentPhotoBeingSaved!){_,_ in
            print("successful deletion!")
            self.currentPhotoBeingSaved = nil
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
extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

