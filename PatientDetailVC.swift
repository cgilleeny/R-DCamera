//
//  PatientDetailVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/16/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit
import CoreImage
import ImageIO

class PatientDetailVC: UIViewController, UIPopoverPresentationControllerDelegate {

    var patient:Patient!
    var exifDict: Dictionary<String, NSObject>?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pupilAnalisysView: PupilAnalisysView!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!

    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = patient.lastName! + "," + patient.firstName!
        
        let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        if let fileURL = documentsDirectory.URLByAppendingPathComponent(patient.lastName! + "-" + patient.firstName! + ".jpg") as NSURL? {
            if let imageSource = CGImageSourceCreateWithURL(fileURL, nil) as CGImageSource? {
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary;
                if let exifAttachmentsDict = imageProperties["{Exif}"] as! Dictionary<String, NSObject>? {
                    self.exifDict = exifAttachmentsDict
                    tapRecognizer.addTarget(self, action: #selector(PatientDetailVC.tapRecognizerHandler))
                    imageView.addGestureRecognizer(tapRecognizer)
                    imageView.userInteractionEnabled = true
                }
            }
            if let imageData = NSData(contentsOfURL : fileURL) as NSData? {
                imageView.image =  UIImage(data: imageData)
            }
        }
        pupilAnalisysView.patient = patient
        pupilAnalisysView.setNeedsDisplay()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionBarButtonItemHandler(sender: UIBarButtonItem) {
        var activityItems: [AnyObject] = [patient.imageURL()]
        do {

            if let csvURL = try patient.saveToCVS() as NSURL? {
                activityItems.append(csvURL)
            }
        } catch {
            print("Error with image URL array")
        }
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop,
                                                        UIActivityTypeAddToReadingList,
                                                        UIActivityTypeAssignToContact,
                                                        UIActivityTypePrint,
                                                        UIActivityTypeCopyToPasteboard,
                                                        UIActivityTypePostToFacebook,
                                                        UIActivityTypeSaveToCameraRoll]
        
        activityViewController.popoverPresentationController?.delegate = self
        
        dispatch_async(dispatch_get_main_queue(), {
            activityViewController.popoverPresentationController?.barButtonItem = self.actionBarButtonItem
            self.presentViewController(activityViewController, animated: true, completion: nil)
        })
    }
    
    func tapRecognizerHandler() {
        performSegueWithIdentifier("FaceAndEyeSegue", sender: nil)
    }


    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "FaceAndEyeSegue" {
            if let faceAndEyeVC = segue.destinationViewController as? FaceAndEyeVC {
                //faceAndEyeVC.image = savedImage!
                faceAndEyeVC.portraitImage = imageView.image
                faceAndEyeVC.exifDict = exifDict!
            }
        }
    }

}
