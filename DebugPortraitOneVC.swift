//
//  DebugPortraitOneVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/8/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class DebugPortraitOneVC: UIViewController {

    @IBOutlet weak var portraitImageView: UIImageView!
    var portraitImage:UIImage!
    var rightEyeImage:UIImage!
    var leftEyeImage:UIImage!
    var rightEyeRect:CGRect!
    var leftEyeRect:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portraitImageView.image = CVWrapper.getDebugMat(portraitImage)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DebugPortraitTwoSegue" {
            if let debugPortraitTwoVC = segue.destinationViewController as? DebugPortraitTwoVC {
                debugPortraitTwoVC.portraitImage = portraitImage!
                debugPortraitTwoVC.rightEyeImage = rightEyeImage!
                debugPortraitTwoVC.leftEyeImage = leftEyeImage!
                debugPortraitTwoVC.rightEyeRect = rightEyeRect!
                debugPortraitTwoVC.leftEyeRect = leftEyeRect!
            }
        }
    }
    

}
