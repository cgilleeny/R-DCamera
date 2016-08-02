//
//  PupilROI.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/13/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import Foundation
import CoreData


class PupilROI: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func create(moc: NSManagedObjectContext, red: UInt32, green: UInt32, blue: UInt32, totalPixels: UInt32) throws -> PupilROI {
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("PupilROI", inManagedObjectContext: moc) as! PupilROI
        entity.red = NSNumber(unsignedInt: red)
        entity.green = NSNumber(unsignedInt: green)
        entity.blue = NSNumber(unsignedInt: blue)
        entity.totalPixels = NSNumber(unsignedInt: totalPixels)
        try moc.save()
        return entity
    }
    
    class func create(moc: NSManagedObjectContext, red: UInt32, green: UInt32, blue: UInt32, totalPixels: UInt32, hueLow: UInt32, satLow: UInt32, valLow: UInt32, lowTotal: UInt32, hueHigh: UInt32, satHigh: UInt32, valHigh: UInt32, highTotal: UInt32) throws -> PupilROI {
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("PupilROI", inManagedObjectContext: moc) as! PupilROI
        entity.red = NSNumber(unsignedInt: red)
        entity.green = NSNumber(unsignedInt: green)
        entity.blue = NSNumber(unsignedInt: blue)
        entity.totalPixels = NSNumber(unsignedInt: totalPixels)
        
        entity.hueLow = NSNumber(unsignedInt: hueLow)
        entity.satLow = NSNumber(unsignedInt: satLow)
        entity.valLow = NSNumber(unsignedInt: valLow)
        entity.lowTotal = NSNumber(unsignedInt: lowTotal)
        
        entity.hueHigh = NSNumber(unsignedInt: hueHigh)
        entity.satHigh = NSNumber(unsignedInt: satHigh)
        entity.valHigh = NSNumber(unsignedInt: valHigh)
        entity.highTotal = NSNumber(unsignedInt: highTotal)
        
        try moc.save()
        return entity
    }

}
