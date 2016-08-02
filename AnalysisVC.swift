//
//  AnalysisVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 7/20/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit
import CoreData
import ImageIO

class AnalysisVC: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var eyeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
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
    @IBOutlet weak var displayTypeLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var pixelCountLabel: UILabel!
    @IBOutlet weak var pixelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var displayTypeSegmentedControl: UISegmentedControl!
    
    //var leftEyeRect:CGRect!
    
    var moc: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
    let cvWrapper: CVWrapper = CVWrapper()
    var portraitImage:UIImage!
    var exifDict: Dictionary<String, AnyObject>?
    var rightEyeImage:UIImage!
    var leftEyeImage:UIImage!
    //var rightEyeRect:CGRect!
    //var leftEyeRect:CGRect!
    var contourRed: UInt32 = 0
    var contourGreen: UInt32 = 0
    var contourBlue: UInt32 = 0
    var contourCount: UInt32 = 0
    var differenceRed: UInt32 = 0
    var differenceGreen: UInt32 = 0
    var differenceBlue: UInt32 = 0
    var differenceCount: UInt32 = 0
    var contourHueLow: UInt32 = 0
    var contourSatLow: UInt32 = 0
    var contourValLow: UInt32 = 0
    var contourCountLow: UInt32 = 0
    var differenceHueLow: UInt32 = 0
    var differenceSatLow: UInt32 = 0
    var differenceValLow: UInt32 = 0
    var differenceCountLow: UInt32 = 0
    var contourHueHigh: UInt32 = 0
    var contourSatHigh: UInt32 = 0
    var contourValHigh: UInt32 = 0
    var contourCountHigh: UInt32 = 0
    var differenceHueHigh: UInt32 = 0
    var differenceSatHigh: UInt32 = 0
    var differenceValHigh: UInt32 = 0
    var differenceCountHigh: UInt32 = 0
    
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
    
    @IBAction func pixelSegmentedControlHandler(sender: UISegmentedControl) {
        updateUI()
    }
    
    @IBAction func displayTypeSegmentedControlHandler(sender: AnyObject) {
        updateUI()
    }
    
    @IBAction func lowerWheelStepperHandler(sender: UIStepper) {
        displayEye()
    }
    
    @IBAction func upperWheelStepperHandler(sender: UIStepper) {
        displayEye()
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
                
                let rgbSumRight:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSumFromPupil(self.rightEyeImage, withUpperWheelMin: UInt8(self.upperWheelStepper.value), withLowerWheelMax: UInt8(self.lowerWheelStepper.value), withMinSkinRatio: self.minSkinRatioSlider.value, withThresh: UInt16(self.threshStepper.value), withRatio: 0.25, withSkinValMultiplier: self.skinValMultiplierSlider.value)
                if rgbSumRight != nil {
                    patient.contourRight = try PupilROI.create(self.moc,
                        red: rgbSumRight[0],
                        green: rgbSumRight[1],
                        blue: rgbSumRight[2],
                        totalPixels: rgbSumRight[3],
                        hueLow: rgbSumRight[8],
                        satLow: rgbSumRight[9],
                        valLow:rgbSumRight[10],
                        lowTotal: rgbSumRight[11],
                        hueHigh: rgbSumRight[12],
                        satHigh: rgbSumRight[13],
                        valHigh:rgbSumRight[14],
                        highTotal: rgbSumRight[15])
                    patient.differenceRight = try PupilROI.create(self.moc,
                        red: rgbSumRight[4],
                        green: rgbSumRight[5],
                        blue: rgbSumRight[6],
                        totalPixels: rgbSumRight[7],
                        hueLow: rgbSumRight[16],
                        satLow: rgbSumRight[17],
                        valLow:rgbSumRight[18],
                        lowTotal: rgbSumRight[19],
                        hueHigh: rgbSumRight[20],
                        satHigh: rgbSumRight[21],
                        valHigh:rgbSumRight[22],
                        highTotal: rgbSumRight[23])
                }
                let rgbSumLeft:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSumFromPupil(self.leftEyeImage, withUpperWheelMin: UInt8(self.upperWheelStepper.value), withLowerWheelMax: UInt8(self.lowerWheelStepper.value), withMinSkinRatio: self.minSkinRatioSlider.value, withThresh: UInt16(self.threshStepper.value), withRatio: 0.25, withSkinValMultiplier: self.skinValMultiplierSlider.value)
                if rgbSumLeft != nil {
                    patient.contourLeft = try PupilROI.create(self.moc,
                        red: rgbSumLeft[0],
                        green: rgbSumLeft[1],
                        blue: rgbSumLeft[2],
                        totalPixels: rgbSumLeft[3],
                        hueLow: rgbSumLeft[8],
                        satLow: rgbSumLeft[9],
                        valLow: rgbSumLeft[10],
                        lowTotal: rgbSumLeft[11],
                        hueHigh: rgbSumLeft[12],
                        satHigh: rgbSumLeft[13],
                        valHigh: rgbSumLeft[14],
                        highTotal: rgbSumLeft[15])
                    patient.differenceLeft = try PupilROI.create(self.moc,
                        red: rgbSumLeft[4],
                        green: rgbSumLeft[5],
                        blue: rgbSumLeft[6],
                        totalPixels: rgbSumLeft[7],
                        hueLow: rgbSumLeft[16],
                        satLow: rgbSumLeft[17],
                        valLow: rgbSumLeft[18],
                        lowTotal: rgbSumLeft[19],
                        hueHigh: rgbSumLeft[20],
                        satHigh: rgbSumLeft[21],
                        valHigh: rgbSumLeft[22],
                        highTotal: rgbSumLeft[23])
                }
                try self.moc.save()
            } catch {
                print("Error saving Patient entity")
            }
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
    
    func updateUI() {
        lowerWheelLabel.text = String(format: "Red 0..%d", Int(lowerWheelStepper.value))
        upperWheelLabel.text = String(format: "Red %d..179", Int(upperWheelStepper.value))
        threshLabel.text = String(format: "Thrsh %d", Int(threshStepper.value))
        skinValMultiplierLabel.text = String(format: "Skin Multiplier Val %f", skinValMultiplierSlider.value)
        minSkinRatioLabel.text = String(format: "Min Skin Ratio %f", minSkinRatioSlider.value)
       
        if pixelSegmentedControl.selectedSegmentIndex == 0 {
            if displayTypeSegmentedControl.selectedSegmentIndex == 0 {
                displayTypeLabel.text = "RGB"
                redLabel.text =  String.localizedStringWithFormat("R: %d, avg. %d",  contourRed,
                      (contourCount == 0) ? 0 : contourRed/contourCount)
                greenLabel.text = String.localizedStringWithFormat("G: %d, avg. %d", contourGreen, (contourCount == 0) ? 0 : contourGreen/contourCount)
                blueLabel.text = String.localizedStringWithFormat("B: %d, avg. %d", contourBlue, (contourCount == 0) ? 0 : contourBlue/contourCount)
                pixelCountLabel.text = "Total: \(contourCount)"
            } else if displayTypeSegmentedControl.selectedSegmentIndex == 1 {
                displayTypeLabel.text = "HSV 0..30"
                redLabel.text =  String.localizedStringWithFormat("H: %d, avg. %d",  contourHueLow,
                                                                  (contourCountLow == 0) ? 0 : contourHueLow/contourCountLow)
                greenLabel.text = String.localizedStringWithFormat("S: %d, avg. %d", contourSatLow, (contourCountLow == 0) ? 0 : contourSatLow/contourCountLow)
                blueLabel.text = String.localizedStringWithFormat("V: %d, avg. %d", contourValLow, (contourCountLow == 0) ? 0 : contourValLow/contourCountLow)
                pixelCountLabel.text = "Total: \(contourCountLow)"
            } else {
                displayTypeLabel.text = "HSV 31..179"
                redLabel.text =  String.localizedStringWithFormat("H: %d, avg. %d",  contourHueHigh,
                                                                  (contourCountHigh == 0) ? 0 : contourHueHigh/contourCountHigh)
                greenLabel.text = String.localizedStringWithFormat("S: %d, avg. %d", contourSatHigh, (contourCountHigh == 0) ? 0 : contourSatHigh/contourCountHigh)
                blueLabel.text = String.localizedStringWithFormat("V: %d, avg. %d", contourValHigh, (contourCountHigh == 0) ? 0 : contourValHigh/contourCountHigh)
                pixelCountLabel.text = "Total: \(contourCountHigh)"
            }
            

        } else if pixelSegmentedControl.selectedSegmentIndex == 1 {

            
            if displayTypeSegmentedControl.selectedSegmentIndex == 0 {
                displayTypeLabel.text = "RGB"
                redLabel.text =  String.localizedStringWithFormat("R: %d, avg. %d", differenceRed, (differenceCount == 0) ? 0 : differenceRed/differenceCount)
                greenLabel.text = String.localizedStringWithFormat("G: %d, avg. %d", differenceGreen, (differenceCount == 0) ? 0 : differenceGreen/differenceCount)
                blueLabel.text = String.localizedStringWithFormat("B: %d, avg. %d", differenceBlue, (differenceCount == 0) ? 0 : differenceBlue/differenceCount)
                pixelCountLabel.text = "Total: \(differenceCount)"
            } else if displayTypeSegmentedControl.selectedSegmentIndex == 1 {
                displayTypeLabel.text = "HSV 0..30"
                redLabel.text =  String.localizedStringWithFormat("H: %d, avg. %d",  differenceHueLow,
                                                                  (differenceCountLow == 0) ? 0 : differenceHueLow/differenceCountLow)
                greenLabel.text = String.localizedStringWithFormat("S: %d, avg. %d", differenceSatLow, (differenceCountLow == 0) ? 0 : differenceSatLow/differenceCountLow)
                blueLabel.text = String.localizedStringWithFormat("V: %d, avg. %d", differenceValLow, (differenceCountLow == 0) ? 0 : differenceValLow/differenceCountLow)
                pixelCountLabel.text = "Total: \(differenceCountLow)"
            } else {
                displayTypeLabel.text = "HSV 31..179"
                redLabel.text =  String.localizedStringWithFormat("H: %d, avg. %d",  differenceHueHigh,
                                                                  (differenceCountHigh == 0) ? 0 : differenceHueHigh/differenceCountHigh)
                greenLabel.text = String.localizedStringWithFormat("S: %d, avg. %d", differenceSatHigh, (differenceCountHigh == 0) ? 0 : differenceSatHigh/differenceCountHigh)
                blueLabel.text = String.localizedStringWithFormat("V: %d, avg. %d", differenceValHigh, (differenceCountHigh == 0) ? 0 : differenceValHigh/differenceCountHigh)
                pixelCountLabel.text = "Total: \(differenceCountHigh)"
            }

            
        } else {

            
            if displayTypeSegmentedControl.selectedSegmentIndex == 0 {
                displayTypeLabel.text = "RGB"
                redLabel.text =  String.localizedStringWithFormat("R: %d, avg. %d", contourRed + differenceRed, (contourCount + differenceCount == 0) ? 0 : (contourRed + differenceRed)/(contourCount + differenceCount))
                greenLabel.text = String.localizedStringWithFormat("G: %d, avg. %d", contourGreen + differenceGreen, (contourCount + differenceCount == 0) ? 0 : (contourGreen + differenceGreen)/(contourCount + differenceCount))
                blueLabel.text = String.localizedStringWithFormat("B: %d, avg. %d", contourBlue + differenceBlue, (contourCount + differenceCount == 0) ? 0 : (contourBlue + differenceBlue)/(contourCount + differenceCount))
                pixelCountLabel.text = "Total: \(contourCount + differenceCount)"
            } else if displayTypeSegmentedControl.selectedSegmentIndex == 1 {
                displayTypeLabel.text = "HSV 0..30"
                redLabel.text =  String.localizedStringWithFormat("H: %d, avg. %d",  contourHueLow + differenceHueLow,
                                                                  (contourCountLow + differenceCountLow == 0) ? 0 : (contourHueLow + differenceHueLow)/(contourCountLow + differenceCountLow))
                greenLabel.text = String.localizedStringWithFormat("S: %d, avg. %d", contourSatLow + differenceSatLow, (contourCountLow + differenceCountLow == 0) ? 0 : (contourSatLow + differenceSatLow)/(contourCountLow + differenceCountLow))
                blueLabel.text = String.localizedStringWithFormat("V: %d, avg. %d", contourValLow + differenceValLow, (contourCountLow + differenceCountLow == 0) ? 0 : (contourValLow + differenceValLow)/(contourCountLow + differenceCountLow))
                pixelCountLabel.text = "Total: \(contourCountLow + differenceCountLow)"
            } else {
                displayTypeLabel.text = "HSV 31..179"
                redLabel.text =  String.localizedStringWithFormat("H: %d, avg. %d", contourHueHigh + differenceHueHigh,
                                                                  (contourCountHigh + differenceCountHigh == 0) ? 0 : (contourHueHigh + differenceHueHigh)/(contourCountHigh + differenceCountHigh))
                greenLabel.text = String.localizedStringWithFormat("S: %d, avg. %d", contourSatHigh + differenceSatHigh, (contourCountHigh + differenceCountHigh == 0) ? 0 : (contourSatHigh + differenceSatHigh)/(contourCountHigh + differenceCountHigh))
                blueLabel.text = String.localizedStringWithFormat("V: %d, avg. %d", contourValHigh + differenceValHigh, (contourCountHigh + differenceCountHigh == 0) ? 0 : (contourValHigh + differenceValHigh)/(contourCountHigh + differenceCountHigh))
                pixelCountLabel.text = "Total: \(contourCountHigh + differenceCountHigh)"
            }
            
        }

    }
    
    func displayEye() {
        imageView.image = CVWrapper.processImage(eyeSegmentedControl.selectedSegmentIndex == 0 ? rightEyeImage : leftEyeImage, withProcessID: 4, withUpperWheelMin: UInt8(upperWheelStepper.value), withLowerWheelMax: UInt8(lowerWheelStepper.value), withMinSkinRatio:minSkinRatioSlider.value , withThresh:UInt16(threshStepper.value), withRatio:0.25, withSkinValMultiplier:skinValMultiplierSlider.value )
        let rgbSum:UnsafeMutablePointer<UInt32> = CVWrapper.getRGBSumFromPupil(eyeSegmentedControl.selectedSegmentIndex == 0 ? rightEyeImage : leftEyeImage, withUpperWheelMin: UInt8(upperWheelStepper.value), withLowerWheelMax: UInt8(lowerWheelStepper.value), withMinSkinRatio: minSkinRatioSlider.value, withThresh: UInt16(threshStepper.value), withRatio: 0.25, withSkinValMultiplier: skinValMultiplierSlider.value)

        if rgbSum != nil {
            contourRed = rgbSum[0]
            contourGreen = rgbSum[1]
            contourBlue = rgbSum[2]
            contourCount = rgbSum[3]
            
            differenceRed = rgbSum[4]
            differenceGreen = rgbSum[5]
            differenceBlue = rgbSum[6]
            differenceCount = rgbSum[7]
            
            contourHueLow = rgbSum[8]
            contourSatLow = rgbSum[9]
            contourValLow = rgbSum[10]
            contourCountLow = rgbSum[11]
            
            contourHueHigh = rgbSum[12]
            contourSatHigh = rgbSum[13]
            contourValHigh = rgbSum[14]
            contourCountHigh = rgbSum[15]
            
            differenceHueLow = rgbSum[16]
            differenceSatLow = rgbSum[17]
            differenceValLow = rgbSum[18]
            differenceCountLow = rgbSum[19]
            
            differenceHueHigh = rgbSum[20]
            differenceSatHigh = rgbSum[21]
            differenceValHigh = rgbSum[22]
            differenceCountHigh = rgbSum[23]
        } else {
            contourRed = 0
            contourGreen = 0
            contourBlue = 0
            contourCount = 0
            
            differenceRed = 0
            differenceGreen = 0
            differenceBlue = 0
            differenceCount = 0
            
            contourHueLow = 0
            contourSatLow = 0
            contourValLow = 0
            contourCountLow = 0
            
            contourHueHigh = 0
            contourSatHigh = 0
            contourValHigh = 0
            contourCountHigh = 0
            
            differenceHueLow = 0
            differenceSatLow = 0
            differenceValLow = 0
            differenceCountLow = 0
            
            differenceHueHigh = 0
            differenceSatHigh = 0
            differenceValHigh = 0
            differenceCountHigh = 0
        }
        updateUI()
    }

    // MARK: - popoverViewController
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
