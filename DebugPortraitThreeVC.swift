//
//  DebugPortraitThreeVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/8/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class DebugPortraitThreeVC: UIViewController, UIPopoverPresentationControllerDelegate{

    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    //@IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eyeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var threshStepper: UIStepper!
    @IBOutlet weak var threshLabel: UILabel!
    @IBOutlet weak var greenThreshLabel: UILabel!
    @IBOutlet weak var greenThreshStepper: UIStepper!
    @IBOutlet weak var blueThreshLabel: UILabel!
    @IBOutlet weak var blueThreshStepper: UIStepper!
    @IBOutlet weak var RGDifferenceLabel: UILabel!
    @IBOutlet weak var RGDifferenceStepper: UIStepper!
    
    
    
    
    var portraitImage:UIImage!
    var exifDict: Dictionary<String, AnyObject>?
    //var exifDict: Dictionary<String, NSObject>?
    var rightEyeImage:UIImage!
    var leftEyeImage:UIImage!
    var rightEyeRect:CGRect!
    var leftEyeRect:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinchGesture.addTarget(self, action: #selector(DebugPortraitThreeVC.zoom(_:)))
        tapGesture.addTarget(self, action: #selector(tapGestureHandler(_:)))
        imageView.addGestureRecognizer(tapGesture)
        displayEye(segmentedControl.selectedSegmentIndex, hemisphere: eyeSegmentedControl.selectedSegmentIndex)
        updateUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eyeSegmentedControlHandler(sender: UISegmentedControl) {
        displayEye(segmentedControl.selectedSegmentIndex, hemisphere:sender.selectedSegmentIndex)
    }

    @IBAction func segmentedControlHandler(sender: UISegmentedControl) {
        displayEye(sender.selectedSegmentIndex, hemisphere: eyeSegmentedControl.selectedSegmentIndex)
    }

    @IBAction func threshStepperHandler(sender: UIStepper) {
        displayEye(segmentedControl.selectedSegmentIndex, hemisphere: eyeSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func greenThreshStepper(sender: UIStepper) {
        displayEye(segmentedControl.selectedSegmentIndex, hemisphere: eyeSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func blueThreshStepperHandler(sender: UIStepper) {
        displayEye(segmentedControl.selectedSegmentIndex, hemisphere: eyeSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func RGDifferenceStepperHandler(sender: UIStepper) {
        displayEye(segmentedControl.selectedSegmentIndex, hemisphere: eyeSegmentedControl.selectedSegmentIndex)
    }
    
    func updateUI() {
        threshLabel.text = "\(threshStepper.value)"
        greenThreshLabel.text = "\(greenThreshStepper.value)"
        blueThreshLabel.text = "\(blueThreshStepper.value)"
        RGDifferenceLabel.text = String(format: "R > G + %d", Int(RGDifferenceStepper.value))
    }

    
    func displayEye(operation: Int, hemisphere: Int) {
        switch(operation) {
        case 0:
            imageView.image = CVWrapper.getSubtractMat(portraitImage, withEyeRect:(hemisphere == 0) ?  rightEyeRect : leftEyeRect, withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            break
        case 1:
            imageView.image = CVWrapper.getEqualizeMat(portraitImage, withEyeRect:(hemisphere == 0) ?  rightEyeRect : leftEyeRect, withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            break
        case 2:
            imageView.image = CVWrapper.getGaussianMat(portraitImage, withEyeRect:(hemisphere == 0) ?  rightEyeRect : leftEyeRect, withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            break
        case 3:
            imageView.image = CVWrapper.getThresholdMat(portraitImage, withEyeRect:(hemisphere == 0) ?  rightEyeRect : leftEyeRect, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh:UTF8Char(blueThreshStepper.value), withRGDifference:UTF8Char(RGDifferenceStepper.value))
            break
        case 4:
            imageView.image = CVWrapper.getDrawContoursMat(portraitImage, withEyeRect:(hemisphere == 0) ?  rightEyeRect : leftEyeRect, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            break
        default:
            imageView.image = CVWrapper.getDrawContoursMat(portraitImage, withEyeRect:(hemisphere == 0) ?  rightEyeRect : leftEyeRect, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            break
        }
        updateUI()
    }

    func zoom(sender:UIPinchGestureRecognizer) {
        
        
        if sender.state == .Ended || sender.state == .Changed {
            
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            var newScale = currentScale*sender.scale
            
            if newScale < 1 {
                newScale = 1
            }
            if newScale > 9 {
                newScale = 9
            }
            
            let transform = CGAffineTransformMakeScale(newScale, newScale)
            
            imageView?.transform = transform
            sender.scale = 1
            
        }
        
    }
    
    
    func tapGestureHandler(sender:UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Recognized {
            let point = sender.locationInView(imageView)
            //print("point(\(point.x),\(point.y))")
            let rgb:[UInt8] = imageView.image!.getPixelColor(point)
            let storyboard : UIStoryboard = UIStoryboard(
                name: "Main",
                bundle: nil)
            if let pixelVC = storyboard.instantiateViewControllerWithIdentifier("PixelVC") as? PixelVC {
                pixelVC.point = point
                pixelVC.rgb = rgb
                
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
        if segue.identifier == "DebugPortraitFourSegue" {
            if let debugPortraitFourVC = segue.destinationViewController as? DebugPortraitFourVC {
                if exifDict != nil {
                    debugPortraitFourVC.exifDict = exifDict!
                }
                
                debugPortraitFourVC.portraitImage = portraitImage!
                debugPortraitFourVC.rightEyeImage = rightEyeImage!
                debugPortraitFourVC.leftEyeImage = leftEyeImage!
                debugPortraitFourVC.rightEyeRect = rightEyeRect!
                debugPortraitFourVC.leftEyeRect = leftEyeRect!
            }
        }
    }

}
