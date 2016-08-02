//
//  HSVVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 7/15/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class HSVVC: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var eyeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var processSegmentedControl: UISegmentedControl!
    @IBOutlet weak var lowerWheelLabel: UILabel!
    @IBOutlet weak var upperWheelLabel: UILabel!
    @IBOutlet weak var lowerWheelStepper: UIStepper!
    @IBOutlet weak var upperWheelStepper: UIStepper!
    @IBOutlet weak var skinValMultiplierSlider: UISlider!
    @IBOutlet weak var threshStepper: UIStepper!
    @IBOutlet weak var skinValMultiplierLabel: UILabel!
    @IBOutlet weak var threshLabel: UILabel!
    @IBOutlet weak var minSkinRatioSlider: UISlider!
    @IBOutlet weak var minSkinRatioLabel: UILabel!
    
    let cvWrapper: CVWrapper = CVWrapper()
    var portraitImage:UIImage!
    var exifDict: Dictionary<String, AnyObject>?
    var rightEyeImage:UIImage!
    var leftEyeImage:UIImage!
    var rightEyeRect:CGRect!
    var leftEyeRect:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGesture.addTarget(self, action: #selector(tapGestureHandler(_:)))
        imageView.addGestureRecognizer(tapGesture)
        displayEye()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func threshStepperHandler(sender: UIStepper) {
        displayEye()
    }
    
    @IBAction func skinValMultiplierSliderHandler(sender: UISlider) {
        displayEye()
    }
    
    @IBAction func minSkinRatioSliderHandler(sender: AnyObject) {
        displayEye()
    }
    
    @IBAction func eyeSegmentedControlHandler(sender: UISegmentedControl) {
        displayEye()
    }

    @IBAction func processSegmentedControlHandler(sender: UISegmentedControl) {
        displayEye()
    }
    
    @IBAction func lowerWheelStepperHandler(sender: UIStepper) {
        displayEye()
    }
    
    @IBAction func upperWheelStepperHandler(sender: UIStepper) {
        displayEye()
    }
    
    
    func updateUI() {
        lowerWheelLabel.text = String(format: "Lower Wheel 0 .. %d", Int(lowerWheelStepper.value))
        upperWheelLabel.text = String(format: "Upper Wheel %d .. 179", Int(upperWheelStepper.value))
        threshLabel.text = String(format: "Thresh %d", Int(threshStepper.value))
        skinValMultiplierLabel.text = String(format: "Skin Multiplier Val %f", skinValMultiplierSlider.value)
        minSkinRatioLabel.text = String(format: "Min Skin Ratio %f", minSkinRatioSlider.value)
    }

    func displayEye() {
        imageView.image = CVWrapper.processImage(eyeSegmentedControl.selectedSegmentIndex == 0 ? rightEyeImage : leftEyeImage, withProcessID: Int32(processSegmentedControl.selectedSegmentIndex), withUpperWheelMin: UInt8(upperWheelStepper.value), withLowerWheelMax: UInt8(lowerWheelStepper.value), withMinSkinRatio:minSkinRatioSlider.value , withThresh:UInt16(threshStepper.value), withRatio:0.25, withSkinValMultiplier:skinValMultiplierSlider.value )
        updateUI()
    }
    
    
    func tapGestureHandler(sender:UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Recognized {
            let point = sender.locationInView(imageView)
            //let rgb:[UInt8] = imageView.image!.getPixelColor(point)
            let storyboard : UIStoryboard = UIStoryboard(
                name: "Main",
                bundle: nil)
            if let pixelVC = storyboard.instantiateViewControllerWithIdentifier("PixelVC") as? PixelVC {
                pixelVC.point = point
                //let hsv: [UTF8Char] = [hsvPtr[0], hsvPtr[1], hsvPtr[2]]
                pixelVC.rgb = imageView.image!.getPixelColor(point)
                if let hsvPtr:UnsafeMutablePointer<UTF8Char> = CVWrapper.rgbPixelToHSV(imageView.image!, atX: Int32(point.x), atY: Int32(point.y)) {
                    pixelVC.hsv[0] = hsvPtr[0]
                    pixelVC.hsv[1] = hsvPtr[1]
                    pixelVC.hsv[2] = hsvPtr[2]
                }
                pixelVC.modalPresentationStyle = .Popover
                pixelVC.preferredContentSize = CGSizeMake(350, 137)
                
                let popoverPixelVC = pixelVC.popoverPresentationController
                popoverPixelVC?.delegate = self
                popoverPixelVC?.sourceView = self.imageView
                popoverPixelVC?.sourceRect = CGRectMake(point.x - 5, point.y - 5, 10.0, 10.0)
                self.presentViewController(
                    pixelVC,
                    animated: true,
                    completion: nil)
            }
        }
    }
    
    // MARK: - popoverViewController
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AnalysisSegue" {
            if let analysisVC = segue.destinationViewController as? AnalysisVC {
                if exifDict != nil {
                    analysisVC.exifDict = exifDict!
                }
                analysisVC.portraitImage = portraitImage!
                analysisVC.rightEyeImage = rightEyeImage!
                analysisVC.leftEyeImage = leftEyeImage!
            }
        }
    }
    

}
