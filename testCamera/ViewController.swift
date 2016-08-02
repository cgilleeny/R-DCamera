//
//  ViewController.swift
//  testCamera
//
//  Created by Bruce Ng on 2/4/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import CoreMedia
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var backCamera: AVCaptureDevice?
    var headOutline:HeadOutlineView?

    var savedImage : UIImage?
    var exifDict: Dictionary<String, NSObject>?
    var startingBrightness: CGFloat!
    
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var brightText: UILabel!

    @IBOutlet weak var isoLabel: UILabel!

    @IBOutlet weak var flashlightBrightnessSlider: UISlider!
    @IBOutlet weak var flaslightStartDelayStepper: UIStepper!
    @IBOutlet weak var isoSlider: UISlider!
    
    @IBOutlet weak var flashlightStartDelayStepper: UIStepper!
    @IBOutlet weak var flashlightStartDelayValueLabel: UILabel!

    @IBOutlet weak var actualISOSlider: UISlider!
    @IBOutlet weak var actualISOLabel: UILabel!

    @IBAction func flashlightStartDelayStepperHandler(sender: AnyObject) {
        flashlightStartDelayValueLabel.text = String(format:"%.2f sec", flaslightStartDelayStepper.value/100.0)
    }
    
    @IBAction func flashlightBrightnesSliderHandler(sender: UISlider) {
        brightText.text = String(format:"%.2f intensity", Float(sender.value))
    }
    
    @IBAction func actualISOSliderHandler(sender: UISlider) {
        actualISOLabel.text = String(format:"%.2f ISO", sender.value)
    }
    
    @IBAction func isoSliderHandler(sender: UISlider) {
        isoLabel.text = String(format:"%.2f ISO", sender.value)
        setISO(sender.value)
    }
    
    
    @IBAction func photoRollBarButtonItemHandler(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(picker, animated: true, completion: nil)
        })
    }
        
    func setISO(iso: Float) {
        if let device = backCamera {
            if device.ISO != iso && iso >= device.activeFormat.minISO && iso <= device.activeFormat.maxISO {
                do { try
                    device.lockForConfiguration()
                    device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: iso, completionHandler: nil)
                    device.unlockForConfiguration()
                } catch {
                    print("Error")
                }
            }
        }
    }
    
    func turnOnFlashlight() {
        if let device = backCamera {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOnWithLevel(self.flashlightBrightnessSlider.value)
                device.unlockForConfiguration()
                NSLog("torch on")
                /*
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(flashlightDurationSlider.value) * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    NSLog("torch duration expired")
                    self.turnOffFlashlight()
                }
                */
            } catch {
                NSLog("Caught Error")
            }
        }
    }
    
    func turnOffFlashlight() {
        if let device = backCamera {
            do {
                try device.lockForConfiguration()
                device.torchMode = AVCaptureTorchMode.Off
                device.unlockForConfiguration()
                NSLog("torch off")
            } catch {
                NSLog("Caught Error")
            }
        }
    }
    
    /*
    func createSystemSoundID() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "roar", "aiff", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        return soundID
    }
    */
    
    @IBAction func takePhotoBarButtonHandler(sender: UIBarButtonItem) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            if let device = backCamera {
                AudioServicesPlaySystemSound(/*1304*/1025)
                do {
                    try device.lockForConfiguration()
                    device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: actualISOSlider.value, completionHandler: { (time) -> Void in
                        if device.hasTorch {
                            if self.flaslightStartDelayStepper.value <= 0 {
                                self.turnOnFlashlight()
                            } else {
                                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(self.flaslightStartDelayStepper.value/100) * Double(NSEC_PER_SEC)))
                                dispatch_after(delayTime, dispatch_get_main_queue()) {
                                    NSLog("torch start delay expired")
                                    self.turnOnFlashlight()
                                }
                            }
                        }
                        if self.flaslightStartDelayStepper.value < 0 {
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(abs(self.flaslightStartDelayStepper.value/100)) * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) {
                                NSLog("torch leed time expired")
                                NSLog("before snapping picture")
                                self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                                    NSLog("snapping picture")
                                    self.turnOffFlashlight()
                                    if (sampleBuffer != nil) {
                                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                                        self.savedImage = UIImage(data: imageData)
                                        if let cfAttachmentsDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) as CFDictionary? {
                                            if let nsAttachmentsDict = cfAttachmentsDict as NSDictionary? {
                                                if let attachmentsDict = nsAttachmentsDict as? Dictionary<String, AnyObject> as Dictionary<String, AnyObject>? {
                                                    if let exifAttachmentsDict = attachmentsDict["{Exif}"] as! Dictionary<String, NSObject>? {
                                                        self.exifDict = exifAttachmentsDict
                                                    }
                                                }
                                            }
                                        }
                                        NSLog("before segue")
                                        self.performSegueWithIdentifier("FaceAndEyeSegue", sender: self)
                                    }
                                })
                            }
                        } else {
                            NSLog("before snapping picture")
                            self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                                NSLog("snapping picture")
                                self.turnOffFlashlight()
                                if (sampleBuffer != nil) {
                                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                                    
                                    self.savedImage = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                                    if let cfAttachmentsDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) as CFDictionary? {
                                        if let nsAttachmentsDict = cfAttachmentsDict as NSDictionary? {
                                            if let attachmentsDict = nsAttachmentsDict as? Dictionary<String, AnyObject> as Dictionary<String, AnyObject>? {
                                                if let exifAttachmentsDict = attachmentsDict["{Exif}"] as! Dictionary<String, NSObject>? {
                                                    self.exifDict = exifAttachmentsDict
                                                }
                                            }
                                        }
                                    }
                                    
                                    NSLog("before segue")
                                    self.performSegueWithIdentifier("FaceAndEyeSegue", sender: self)
                                }
                            })
                        }
                    })
                    device.unlockForConfiguration()
                } catch {
                    print("Failed ISO")
                }
            }
        }
    }
    
    /*
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        NSLog("didOutputMetadataObjects")
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        prepareAVCaptureSession()
        
        /*
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                if captureSession!.canAddOutput(stillImageOutput) {
                    captureSession!.addOutput(stillImageOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    //previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                    preview!.layer.addSublayer(previewLayer!)
                    
                    //captureSession!.startRunning()
                }
            }
            /*
            flashlightStartDelayValueLabel.text = String(format:"%.2f sec", flaslightStartDelayStepper.value/100.0)
            brightText.text = String(format:"%.2f intensity", flashlightBrightnessSlider.value)
            if let device = backCamera {
                isoSlider.maximumValue = device.activeFormat.maxISO
                isoSlider.minimumValue = device.activeFormat.minISO
                //isoSlider.value = device.ISO
                isoLabel.text = String(format:"%.2f ISO", isoSlider.value)
                actualISOSlider.maximumValue = device.activeFormat.maxISO
                actualISOSlider.minimumValue = device.activeFormat.minISO
                //actualISOSlider.value = device.ISO
                actualISOLabel.text = String(format:"%.2f ISO", actualISOSlider.value)
            }
            */
        } catch {
            print("poop")
        }
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
        
        UIScreen.mainScreen().brightness = 1.0
        setISO(isoSlider.value)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        print("preview.frame: \(preview.frame), preview.bounds: \(preview.bounds)")
        
        //let bounds:CGRect = preview.layer.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.bounds = preview.layer.bounds
        previewLayer?.position = CGPointMake(CGRectGetMidX(preview.layer.bounds), CGRectGetMidY(preview.layer.bounds))
        captureSession!.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.mainScreen().brightness = startingBrightness
        captureSession!.stopRunning()
    }
    
    deinit{
        print("ViewController deinit")
    }
    
    // MARK: - Utilities
    
    func updateUI() {
        flashlightStartDelayValueLabel.text = String(format:"%.2f sec", flaslightStartDelayStepper.value/100.0)
        brightText.text = String(format:"%.2f intensity", flashlightBrightnessSlider.value)
        actualISOLabel.text = String(format:"%.2f ISO", actualISOSlider.value)
        isoLabel.text = String(format:"%.2f ISO", isoSlider.value)
    }
    
    func prepareAVCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                if captureSession!.canAddOutput(stillImageOutput) {
                    captureSession!.addOutput(stillImageOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                    preview!.layer.addSublayer(previewLayer!)
                }
            }
        } catch {
            print("poop")
        }
    }
    
    /*
    func deinitAVCaptureSession() {
        captureSession!.stopRunning()
        previewLayer!.removeFromSuperlayer()
        captureSession = nil
        backCamera = nil
        stillImageOutput = nil
        previewLayer = nil
    }
    */
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.savedImage = image
            //if let fileURL = info[UIImagePickerControllerReferenceURL] as! NSURL? {
            performSegueWithIdentifier("FaceAndEyeSegue", sender: nil)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "FaceAndEyeSegue" {
            if let faceAndEyeVC = segue.destinationViewController as? FaceAndEyeVC {
                //faceAndEyeVC.image = savedImage!
                faceAndEyeVC.portraitImage = savedImage!.reclassifyAsPortrait()
                if exifDict != nil {
                    faceAndEyeVC.exifDict = exifDict!
                }
            }
        }
    }
    
    /*
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if let cfAttachmentsDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) as CFDictionary? {
            //print("cfAttachmentsDict: \(cfAttachmentsDict)")
            if let nsAttachmentsDict = cfAttachmentsDict as NSDictionary? {
                //print("nsAttachmentsDict: \(nsAttachmentsDict)")
                if let attachmentsDict = nsAttachmentsDict as? Dictionary<String, AnyObject> as Dictionary<String, AnyObject>? {
                    //print("attachmentsDict: \(attachmentsDict)")
                    if let exifDict = attachmentsDict["{Exif}"] as! Dictionary<String, NSObject>? {
                        //print("exifDict: \(exifDict)")
                        if let brightness = exifDict["BrightnessValue"] as! NSNumber? {
                            print("brightness: \(brightness)")
                        }
                    }
                }
            }
            
        }
    }
    */
}

