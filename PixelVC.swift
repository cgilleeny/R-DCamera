//
//  PixelVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/30/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

class PixelVC: UIViewController {

    var rgb:[UInt8]!
    var hsv:[UTF8Char] = [0, 0, 0];
    var point:CGPoint!
    
    @IBOutlet weak var rgbLabel: UILabel!
    @IBOutlet weak var hsvLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let color = CIColor(red: CGFloat(rgb[0]), green: CGFloat(rgb[1]), blue: CGFloat(rgb[2]))
        //let uiColor = UIColor(CIColor: color)
        
        rgbLabel.text = String(format: "(%d, %d) r=%d, g=%d, b=%d", Int(point.x), Int(point.y), rgb[0], rgb[1], rgb[2])
        
        //var hsv: [CGFloat] = [0.0, 0.0, 0.0, 0.0]
        //uiColor.getHue(&hsv[0], saturation: &hsv[1], brightness: &hsv[2], alpha: &hsv[3])
        
        
        hsvLabel.text = String(format: "(%d, %d) h=%d, s=%d, v=%d", Int(point.x), Int(point.y), hsv[0], hsv[1], hsv[2])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
