//
//  LightMeterVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 5/6/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import CoreMedia
import ImageIO

class LightMeterVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var videoImageOutput: AVCaptureVideoDataOutput?
    var backCamera: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var iso: Float = 0.0
    
    
    @IBOutlet weak var brightnessProgressView: UIProgressView!
    @IBOutlet weak var brightnessLabel: UILabel!
    @IBOutlet weak var preview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        var input: AVCaptureDeviceInput!
        
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
                    
                videoImageOutput = AVCaptureVideoDataOutput()
                videoImageOutput?.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
                if captureSession!.canAddOutput(videoImageOutput) {
                    captureSession!.addOutput(videoImageOutput)
                }
                
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                preview!.layer.addSublayer(previewLayer!)
                //captureSession?.startRunning()
                //iso = backCamera!.ISO
                //print("iso: \(iso)")
            }
        } catch {
            print("poop")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("LightMeter viewWillAppear")
        let midISO = backCamera!.activeFormat.minISO + (backCamera!.activeFormat.maxISO - backCamera!.activeFormat.minISO)/2
        print("minISO + (max - min)/2: \(midISO)")
        setISO(midISO)
        //preview!.layer.addSublayer(previewLayer!)
        captureSession?.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("LightMeter viewDidAppear")
        previewLayer!.frame = preview.bounds
        /*
        do {
            try backCamera!.lockForConfiguration()
            backCamera!.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: backCamera!.activeFormat.minISO, completionHandler: { (time) -> Void in
                print("not poop")
            })
            backCamera!.unlockForConfiguration()
        } catch {
            print("poop")
        }
        */
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("LightMeterVC viewDidDisappear")
        //iso = backCamera!.ISO
        //print("iso: \(iso)")
        captureSession?.stopRunning()
        //previewLayer?.removeFromSuperlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePictureButtonHandler(sender: UIBarButtonItem) {
        //captureSession?.stopRunning()
        self.performSegueWithIdentifier("pictureSegue", sender: self)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        //print("UIScreen.mainScreen().brightness: \(UIScreen.mainScreen().brightness)")
        if let cfAttachmentsDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) as CFDictionary? {
            if let nsAttachmentsDict = cfAttachmentsDict as NSDictionary? {
                if let attachmentsDict = nsAttachmentsDict as? Dictionary<String, AnyObject> as Dictionary<String, AnyObject>? {
                    if let exifDict = attachmentsDict["{Exif}"] as! Dictionary<String, NSObject>? {
                        if let brightness = exifDict[kCGImagePropertyExifBrightnessValue.swiftString()] as! NSNumber? {
                            brightnessLabel.text = String(format:"Brightness: %.2f", brightness.floatValue)
                            brightnessProgressView.progress = (brightness.floatValue + 10.0)/20.0
                        }
                    }
                }
            }
        }
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
    

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pictureSegue") {
            if let viewController = segue.destinationViewController as? ViewController {
                viewController.startingBrightness = UIScreen.mainScreen().brightness
            }
            captureSession?.stopRunning()
        }
    }
    
}
