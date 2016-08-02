//
//  FaceAndEyeVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/6/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class FaceAndEyeVC: UIViewController {

    let faceToEyeRatio: CGFloat = 0.18
    var exifDict: Dictionary<String, AnyObject>?
    
    @IBOutlet weak var rightEye: UIImageView!
    @IBOutlet weak var leftEye: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var hsvButton: UIBarButtonItem!
    
    var portraitImage:UIImage?
    var rightEyeImage:UIImage?
    var leftEyeImage:UIImage?
    var rightEyeRect:CGRect?
    var leftEyeRect:CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.contentMode = .ScaleAspectFill
        //self.imageView.image = image
        self.imageView.image = portraitImage!
        nextButton.enabled = false;
        findFeatures()
        //highlightEyes()
    }
    
    /*
    @IBAction func saveImageBarButtonItemHandler(sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil);
    }
    */
    
    func reclassifyAsPortrait(inImage: UIImage) -> UIImage {
        //let imageBounds = CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height)
        //print(imageBounds)
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, inImage.scale)
        let context = UIGraphicsGetCurrentContext()
        //CGContextDrawImage(context, CGRectMake(0.0, 0.0, inImage.size.width, inImage.size.height), inImage.CGImage)
        UIGraphicsPushContext(context!)
        inImage.drawInRect(CGRectMake(0.0, 0.0, inImage.size.width, inImage.size.height))
        UIGraphicsPopContext()
        
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outImage
    }
    
    func findFeatures() {
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: nil)
        
        let faces = faceDetector.featuresInImage(CIImage(image: portraitImage!)!)
        
        UIGraphicsBeginImageContext(portraitImage!.size)
        let context = UIGraphicsGetCurrentContext()

        portraitImage?.drawInRect(CGRectMake(0, 0, portraitImage!.size.width, portraitImage!.size.height))
        
        var transform = CGAffineTransformMakeScale(1, -1)
        transform = CGAffineTransformTranslate(transform,
                                               0, -imageView.bounds.size.height);

        if (faces.count > 0) {
            if let face = faces.first as? CIFaceFeature {
                let faceRect = CGRectApplyAffineTransform(face.bounds, transform)
                print("faceRect: \(faceRect), face.bounds: \(face.bounds)")
                CGContextSetFillColorWithColor(context, UIColor.blueColor().CGColor)
                CGContextSetLineWidth(context, 10.0)
                
                CGContextStrokeRect(context, faceRect);
                CGContextStrokePath(context)
                
                if face.hasLeftEyePosition {
                    let eyeY = portraitImage!.size.height - face.leftEyePosition.y - (face.bounds.height * faceToEyeRatio)
                    if let eyeRect = CGRect(x: face.leftEyePosition.x - (face.bounds.height * faceToEyeRatio)/2, y: eyeY + (face.bounds.height * faceToEyeRatio)/2, width: face.bounds.height * faceToEyeRatio, height: face.bounds.height * faceToEyeRatio) as CGRect? {
                        print("eyeRect: \(eyeRect)")
                        if let cgEyeImage = CGImageCreateWithImageInRect(portraitImage!.CGImage, eyeRect) as CGImage? {
                            rightEyeImage = UIImage(CGImage:cgEyeImage)
                            rightEyeRect = eyeRect
                            rightEye.image = UIImage(CGImage:cgEyeImage)
                        }
                        CGContextStrokeRect(context, eyeRect)
                        CGContextStrokePath(context)
                    }
                }
                
                if face.hasRightEyePosition {
                    let eyeY = portraitImage!.size.height - face.rightEyePosition.y - (face.bounds.height * faceToEyeRatio)
                    if let eyeRect = CGRect(x: face.rightEyePosition.x - (face.bounds.height * faceToEyeRatio)/2, y: eyeY + (face.bounds.height * faceToEyeRatio)/2, width: face.bounds.height * faceToEyeRatio, height: face.bounds.height * faceToEyeRatio) as CGRect? {
                        print("eyeRect: \(eyeRect)")
                        if let cgEyeImage = CGImageCreateWithImageInRect(portraitImage!.CGImage, eyeRect) as CGImage? {
                            leftEye.image = UIImage(CGImage:cgEyeImage)
                            leftEyeImage = UIImage(CGImage:cgEyeImage)
                            if rightEyeRect != nil {
                                nextButton.enabled = true
                                hsvButton.enabled = true
                            }
                            leftEyeRect = eyeRect
                        }
                        CGContextStrokeRect(context, eyeRect)
                        CGContextStrokePath(context)
                    }
                }
            }
        }
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DebugPortraitThreeSegue" {
            if let debugPortraitThreeVC = segue.destinationViewController as? DebugPortraitThreeVC {
                if exifDict != nil {
                    debugPortraitThreeVC.exifDict = exifDict!
                }
                
                debugPortraitThreeVC.portraitImage = portraitImage!
                debugPortraitThreeVC.rightEyeImage = rightEyeImage!
                debugPortraitThreeVC.leftEyeImage = leftEyeImage!
                debugPortraitThreeVC.rightEyeRect = rightEyeRect!
                debugPortraitThreeVC.leftEyeRect = leftEyeRect!
            }
        } else if segue.identifier == "HSVSegue" {
            if let hsvVC = segue.destinationViewController as? HSVVC {
                if exifDict != nil {
                    hsvVC.exifDict = exifDict!
                }
                
                hsvVC.portraitImage = portraitImage!
                hsvVC.rightEyeImage = rightEyeImage!
                hsvVC.leftEyeImage = leftEyeImage!
                hsvVC.rightEyeRect = rightEyeRect!
                hsvVC.leftEyeRect = leftEyeRect!
            }
        }
    }

}
