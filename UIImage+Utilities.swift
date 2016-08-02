//
//  UIImage+Utilities.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/6/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit

extension UIImage {
    
    func reclassifyAsPortrait() -> UIImage {

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()

        UIGraphicsPushContext(context!)
        self.drawInRect(CGRectMake(0.0, 0.0, self.size.width, self.size.height))
        UIGraphicsPopContext()
        
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outImage
    }
    
    func saveToJPG(name: String) -> NSURL? {
        let jpgImageData = UIImageJPEGRepresentation(self, 1.0)   // if you want to save as JPEG
        let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = documentsDirectory.URLByAppendingPathComponent(name)
        let success = jpgImageData!.writeToURL(fileURL, atomically: true)
        if success {
            return fileURL
        }
        return nil
    }
    
    func getPixelColor(pos: CGPoint) -> [UInt8] {
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        /*
        print(String(format: "pos: %d, (%d, %d) - data[pixelInfo]: %f, data[pixelInfo+1]: %f, data[pixelInfo+2]: %f, data[pixelInfo+3]: %f", ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4,
            Int(pos.x), Int(pos.y), CGFloat(data[pixelInfo]), CGFloat(data[pixelInfo+1]), CGFloat(data[pixelInfo+2]), CGFloat(data[pixelInfo+3])))
        */
        
        var rgb = [UInt8](count: 4, repeatedValue: 0)
        rgb[0] = data[pixelInfo]
        rgb[1] = data[pixelInfo+1]
        rgb[2] = data[pixelInfo+2]
        rgb[3] = data[pixelInfo+3]
        //let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        //let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        //let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        //let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        //return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        return rgb
    }
    
}
