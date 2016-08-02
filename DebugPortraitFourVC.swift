//
//  DebugPortraitFourVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/9/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit
import CoreData
import ImageIO

// Sigma X 220
// Sigma Y 255
//self.leftEyeView.image = CVWrapper.findPupils(rightEyeImage, withThresh: Int64(gaussianBlurSigmaX!), withMaxValue: Int64(gaussianBlurSigmaY!))

class DebugPortraitFourVC: UIViewController, UIPopoverPresentationControllerDelegate  {

    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var threshStepper: UIStepper!
    @IBOutlet weak var areaAlgorithmSegmentedController: UISegmentedControl!
    //@IBOutlet weak var actionBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var pixelCountLabel: UILabel!
    @IBOutlet weak var threshLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var greenThreshLabel: UILabel!
    @IBOutlet weak var greenThreshStepper: UIStepper!
    @IBOutlet weak var blueThreshLabel: UILabel!
    @IBOutlet weak var blueThreshStepper: UIStepper!
    
    var portraitImage:UIImage!
    var exifDict: Dictionary<String, AnyObject>?
    var rightEyeImage:UIImage!
    var leftEyeImage:UIImage!
    var rightEyeRect:CGRect!
    var leftEyeRect:CGRect!

    var moc: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
    
    /*
    var csvURL:NSURL?
    var jpgURL:NSURL?
    
    lazy var activityViewController:UIActivityViewController = {
        var activityItems: [AnyObject]
        if self.jpgURL != nil {
            activityItems = [self.csvURL!, self.jpgURL!]
        } else {
            activityItems = [self.csvURL!]
        }
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop,
                                            UIActivityTypeAddToReadingList,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypePrint,
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypePostToFacebook,
                                            UIActivityTypeSaveToCameraRoll]
        
        //activityVC.popoverPresentationController?.barButtonItem = self.actionBarButtonItem
        activityVC.popoverPresentationController?.delegate = self
        return activityVC
    }()
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.enabled = true
        pinchGesture.addTarget(self, action: #selector(DebugPortraitFourVC.zoom(_:)))
        tapGesture.addTarget(self, action: #selector(tapGestureHandler(_:)))
        imageView.addGestureRecognizer(tapGesture)
        imageView.userInteractionEnabled = true
        displayEye()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func areaAlgorithSegmentedControlHandler(sender: UISegmentedControl) {
        displayEye()
    }
    
    @IBAction func threshStepperHandler(sender: UIStepper) {
        displayEye()
    }
    
    @IBAction func greenThreshStepperHandler(sender: UIStepper) {
        displayEye()
    }
    
    @IBAction func blueThreshStepperHandler(sender: AnyObject) {
        displayEye()
    }
    
    @IBAction func sliderHandler(sender: UISlider) {
        displayEye()
    }
    
    @IBAction func segmentedControlHandler(sender: UISegmentedControl) {
        displayEye()
    }
    
    @IBAction func saveBarBottonItemHandler(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
            alert -> Void in
            
            let firstNameTextField = alertController.textFields![0] as UITextField
            let lastNameTextField = alertController.textFields![1] as UITextField
            let dateOfBirthTextField = alertController.textFields![2] as UITextField
            self.portraitImage.saveToJPG(lastNameTextField.text! + "-" + firstNameTextField.text! + ".jpg")
            
            var brightness: Float = 0.0
            var iso = 0
            if self.exifDict != nil {
                if let brightnessValue:NSNumber = self.exifDict![kCGImagePropertyExifBrightnessValue as String] as! NSNumber? {
                    brightness = Float(brightnessValue)
                }
                if let isoValues = self.exifDict![kCGImagePropertyExifISOSpeedRatings.swiftString()] as! NSArray? {
                    do {
                        if isoValues.count > 0 {
                            iso = isoValues[0] as! Int
                        }
                    }
                }
            }
            do {
                let patient = try Patient.create(self.moc, firstName: firstNameTextField.text ?? "John", lastName: lastNameTextField.text ?? "Doe", dateOfBirth: dateOfBirthTextField.text ?? "", luminance: brightness, iso: iso)
                if let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSum(self.portraitImage, withEyeRect:self.rightEyeRect, withRatio: self.slider.value, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(self.greenThreshStepper.value), withBlueThresh: UTF8Char(self.blueThreshStepper.value)) {
                    let contour = try PupilROI.create(self.moc, red: rgbSum[0], green: rgbSum[1], blue: rgbSum[2], totalPixels: rgbSum[3])
                    let difference = try PupilROI.create(self.moc, red: rgbSum[4], green: rgbSum[5], blue: rgbSum[6], totalPixels: rgbSum[7])
                    patient.contourRight = contour
                    patient.differenceRight = difference
                }
                if let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSum(self.portraitImage, withEyeRect:self.leftEyeRect, withRatio: self.slider.value, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(self.greenThreshStepper.value), withBlueThresh: UTF8Char(self.blueThreshStepper.value)) {
                    let contour = try PupilROI.create(self.moc, red: rgbSum[0], green: rgbSum[1], blue: rgbSum[2], totalPixels: rgbSum[3])
                    let difference = try PupilROI.create(self.moc, red: rgbSum[4], green: rgbSum[5], blue: rgbSum[6], totalPixels: rgbSum[7])
                    patient.contourLeft = contour
                    patient.differenceLeft = difference
                }
                try self.moc.save()
            } catch {
                print("Error saving Patient entity")
            }

            /*
            if let brightness:NSNumber = self.exifDict![kCGImagePropertyExifBrightnessValue as String] as! NSNumber? {
                if let isoValues = self.exifDict![kCGImagePropertyExifISOSpeedRatings.swiftString()] as! NSArray? {
                    do {
                        var iso: Int =  0
                        for isoValue in isoValues {
                            print("isoValue: \(isoValue)")
                        }
                        if isoValues.count > 0 {
                            iso = isoValues[0] as! Int
                        }
                        let patient = try Patient.create(self.moc, firstName: firstNameTextField.text ?? "John", lastName: lastNameTextField.text ?? "Doe", dateOfBirth: dateOfBirthTextField.text ?? "", luminance: Float(brightness), iso: iso)
                        if let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSum(self.portraitImage, withEyeRect:self.rightEyeRect, withRatio: self.slider.value, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(self.greenThreshStepper.value), withBlueThresh: UTF8Char(self.blueThreshStepper.value)) {
                            let contour = try PupilROI.create(self.moc, red: rgbSum[0], green: rgbSum[1], blue: rgbSum[2], totalPixels: rgbSum[3])
                            let difference = try PupilROI.create(self.moc, red: rgbSum[4], green: rgbSum[5], blue: rgbSum[6], totalPixels: rgbSum[7])
                            patient.contourRight = contour
                            patient.differenceRight = difference
                        }
                        if let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSum(self.portraitImage, withEyeRect:self.leftEyeRect, withRatio: self.slider.value, withThresh:Int64(self.threshStepper.value), withGreenThresh: UTF8Char(self.greenThreshStepper.value), withBlueThresh: UTF8Char(self.blueThreshStepper.value)) {
                            let contour = try PupilROI.create(self.moc, red: rgbSum[0], green: rgbSum[1], blue: rgbSum[2], totalPixels: rgbSum[3])
                            let difference = try PupilROI.create(self.moc, red: rgbSum[4], green: rgbSum[5], blue: rgbSum[6], totalPixels: rgbSum[7])
                            patient.contourLeft = contour
                            patient.differenceLeft = difference
                        }
                        try self.moc.save()
                    } catch {
                        print("Error saving Patient entity")
                    }
                }
            }
            */
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "First Name"
        }
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Second Name"
        }
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "DOB MM/dd/yyyy"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateUI(red: UInt32, green: UInt32, blue: UInt32, count: UInt32) {
        redLabel.text =  String.localizedStringWithFormat("Red: %d, avg. %d", red, (count == 0) ? 0 : red/count)
        greenLabel.text = String.localizedStringWithFormat("Green: %d, avg. %d", green, (count == 0) ? 0 : green/count)
        blueLabel.text = String.localizedStringWithFormat("Blue: %d, avg. %d", blue, (count == 0) ? 0 : blue/count)
        pixelCountLabel.text = "Pixel Count: \(count)"
        ratioLabel.text = "Contour Ratio: \(slider.value)"
        threshLabel.text = "\(threshStepper.value)"
        greenThreshLabel.text = "\(greenThreshStepper.value)"
        blueThreshLabel.text = "\(blueThreshStepper.value)"
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

    func displayEye() {
        print("imageView.bounds: \(imageView.bounds)")
        imageView.sizeToFit()
        if areaAlgorithmSegmentedController.selectedSegmentIndex == 0 {
            imageView.image = CVWrapper.getDrawLargestContour(portraitImage, withEyeRect: (segmentedControl.selectedSegmentIndex == 0) ?  rightEyeRect : leftEyeRect, withRatio: slider.value, withThresh: Int64(threshStepper.value), withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            print("imageView.bounds: \(imageView.bounds)")
            let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getPupilRGBSum(portraitImage, withThresh:Int64(threshStepper.value), withEyeRect:(segmentedControl.selectedSegmentIndex == 0) ?  rightEyeRect : leftEyeRect, withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            print("rgbSum[0]: \(rgbSum[0]), rgbSum[1]: \(rgbSum[1]), rgbSum[2]: \(rgbSum[2]), rgbSum[3]: \(rgbSum[3])")
            updateUI(rgbSum[0], green: rgbSum[1], blue: rgbSum[2], count: rgbSum[3])
        } else if areaAlgorithmSegmentedController.selectedSegmentIndex == 1 {
            imageView.image = CVWrapper.getDrawMinCircleLargestContour(portraitImage, withEyeRect: (segmentedControl.selectedSegmentIndex == 0) ?  rightEyeRect : leftEyeRect, withRatio: slider.value, withThresh: Int64(threshStepper.value), withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            print("imageView.bounds: \(imageView.bounds)")
            let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getMinCircleRGBSum(portraitImage, withThresh:Int64(threshStepper.value), withEyeRect:(segmentedControl.selectedSegmentIndex == 0) ?  rightEyeRect : leftEyeRect, withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            print("rgbSum[0]: \(rgbSum[0]), rgbSum[1]: \(rgbSum[1]), rgbSum[2]: \(rgbSum[2]), rgbSum[3]: \(rgbSum[3])")
            updateUI(rgbSum[0], green: rgbSum[1], blue: rgbSum[2], count: rgbSum[3])
        } else {
            imageView.image = CVWrapper.getDrawMinCircleLargestContour(portraitImage, withEyeRect: (segmentedControl.selectedSegmentIndex == 0) ?  rightEyeRect : leftEyeRect, withRatio: slider.value, withThresh: Int64(threshStepper.value), withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            print("imageView.bounds: \(imageView.bounds)")
            let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getDifferenceRGBSum(portraitImage, withThresh:Int64(threshStepper.value), withEyeRect:(segmentedControl.selectedSegmentIndex == 0) ?  rightEyeRect : leftEyeRect, withGreenThresh: UTF8Char(greenThreshStepper.value), withBlueThresh: UTF8Char(blueThreshStepper.value))
            print("rgbSum[0]: \(rgbSum[0]), rgbSum[1]: \(rgbSum[1]), rgbSum[2]: \(rgbSum[2]), rgbSum[3]: \(rgbSum[3])")
            updateUI(rgbSum[0], green: rgbSum[1], blue: rgbSum[2], count: rgbSum[3])
        }
    }

    
    // MARK: - popoverViewController
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    /*
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if popoverPresentationController.presentedViewController as? UIActivityViewController != nil {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
