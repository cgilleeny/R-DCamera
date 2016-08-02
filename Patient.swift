//
//  Patient.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/13/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import Foundation
import CoreData


class Patient: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func create(moc: NSManagedObjectContext, firstName: String, lastName: String, dateOfBirth: String, luminance: Float, iso: Int) throws -> Patient {

        let entity = NSEntityDescription.insertNewObjectForEntityForName("Patient", inManagedObjectContext: moc) as! Patient
        entity.firstName = firstName
        entity.lastName = lastName
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if let DOB = dateFormatter.dateFromString(dateOfBirth) {
            entity.dateOfBirth = DOB
            //print("dateOfBirth: \(dateOfBirth), DOB: \(DOB), entity.dateOfBirth: \(entity.dateOfBirth)")
        }
        
        entity.luminance = luminance
        entity.iso = iso
        try moc.save()
        return entity
    }

    func toCSV() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YY"
        
        var DOBString = ""
        if let dateOfBirth = self.dateOfBirth as NSDate? {
            DOBString = dateFormatter.stringFromDate(dateOfBirth)
        }
        
        var isoInt = 0
        if let iso = self.iso as NSNumber? {
            isoInt = Int(iso)
        }
        
        var luminanceFloat = Float(0.0)
        if let luminance = self.luminance as NSNumber? {
            luminanceFloat = Float(luminance)
        }
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        
        

        let csvHeader = String(format: "first name, %@, last name, %@, DOB, %@, brightness,%f, iso,%d\n,Pixel Values:\n,Left Eye Contour Total,Left Eye Contour Avg., Right Eye Contour Total, Right Eye Contour Avg., Left Eye Difference Total, Left Eye Difference Avg., Right Eye Difference Total, Right Eye Difference Avg., Left Eye Total, Left Eye Total Avg., Right Eye Total, Right Eye Total Avg. \n",self.firstName ?? "", self.lastName ?? "", DOBString , luminanceFloat, isoInt)
        let redFields = String(format: "red, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.red!),
                               (Int(self.contourLeft!.totalPixels!) == 0) ? 0 : Int(self.contourLeft!.red!)/Int(self.contourLeft!.totalPixels!),
                               Int(self.contourRight!.red!),
                               (Int(self.contourRight!.totalPixels!) == 0) ? 0 : Int(self.contourRight!.red!)/Int(self.contourRight!.totalPixels!),
                               Int(self.differenceLeft!.red!),
                               (Int(self.differenceLeft!.totalPixels!) == 0) ? 0 : Int(self.differenceLeft!.red!)/Int(self.differenceLeft!.totalPixels!),
                               Int(self.differenceRight!.red!),
                               (Int(self.differenceRight!.totalPixels!) == 0) ? 0 : Int(self.differenceRight!.red!)/Int(self.differenceRight!.totalPixels!),
                               Int(self.contourLeft!.red!) + Int(self.differenceLeft!.red!),
                               (Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!) == 0) ? 0 : (Int(self.contourLeft!.red!) + Int(self.differenceLeft!.red!))/(Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!)),
                               Int(self.contourRight!.red!) + Int(self.differenceRight!.red!),
                               (Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!) == 0) ? 0 : (Int(self.contourRight!.red!) + Int(self.differenceRight!.red!))/(Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!))
                                )

        let greenFields = String(format: "green, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.green!),
                               (Int(self.contourLeft!.totalPixels!) == 0) ? 0 : Int(self.contourLeft!.green!)/Int(self.contourLeft!.totalPixels!),
                               Int(self.contourRight!.green!),
                               (Int(self.contourRight!.totalPixels!) == 0) ? 0 : Int(self.contourRight!.green!)/Int(self.contourRight!.totalPixels!),
                               Int(self.differenceLeft!.green!),
                               (Int(self.differenceLeft!.totalPixels!) == 0) ? 0 : Int(self.differenceLeft!.green!)/Int(self.differenceLeft!.totalPixels!),
                               Int(self.differenceRight!.green!),
                               (Int(self.differenceRight!.totalPixels!) == 0) ? 0 : Int(self.differenceRight!.green!)/Int(self.differenceRight!.totalPixels!),
                               Int(self.contourLeft!.green!) + Int(self.differenceLeft!.green!),
                               (Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!) == 0) ? 0 : (Int(self.contourLeft!.green!) + Int(self.differenceLeft!.green!))/(Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!)),
                               Int(self.contourRight!.green!) + Int(self.differenceRight!.green!),
                               (Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!) == 0) ? 0 : (Int(self.contourRight!.green!) + Int(self.differenceRight!.green!))/(Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!))
        )
        
        let blueFields = String(format: "blue, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.blue!),
                                 (Int(self.contourLeft!.totalPixels!) == 0) ? 0 : Int(self.contourLeft!.blue!)/Int(self.contourLeft!.totalPixels!),
                                 Int(self.contourRight!.blue!),
                                 (Int(self.contourRight!.totalPixels!) == 0) ? 0 : Int(self.contourRight!.blue!)/Int(self.contourRight!.totalPixels!),
                                 Int(self.differenceLeft!.blue!),
                                 (Int(self.differenceLeft!.totalPixels!) == 0) ? 0 : Int(self.differenceLeft!.blue!)/Int(self.differenceLeft!.totalPixels!),
                                 Int(self.differenceRight!.blue!),
                                 (Int(self.differenceRight!.totalPixels!) == 0) ? 0 : Int(self.differenceRight!.blue!)/Int(self.differenceRight!.totalPixels!),
                                 Int(self.contourLeft!.blue!) + Int(self.differenceLeft!.blue!),
                                 (Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!) == 0) ? 0 : (Int(self.contourLeft!.blue!) + Int(self.differenceLeft!.blue!))/(Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!)),
                                 Int(self.contourRight!.blue!) + Int(self.differenceRight!.blue!),
                                 (Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!) == 0) ? 0 : (Int(self.contourRight!.blue!) + Int(self.differenceRight!.blue!))/(Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!))
        )
        
        //let minCircleTotal = NSNumber(integer: Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!))
        
        let rgbTotalPixelFields = String(format: "total pixels, %@, N/A, %@, N/A, %@, N/A, %@, N/A, %@, N/A, %@, N/A\n"
            , numberFormatter.stringFromNumber(self.contourLeft!.totalPixels!)!
            , numberFormatter.stringFromNumber(self.contourRight!.totalPixels!)!
            , numberFormatter.stringFromNumber(self.differenceLeft!.totalPixels!)!
            , numberFormatter.stringFromNumber(self.differenceRight!.totalPixels!)!
            , numberFormatter.stringFromNumber(NSNumber(integer: Int(self.contourLeft!.totalPixels!) + Int(self.differenceLeft!.totalPixels!)))!
            , numberFormatter.stringFromNumber(NSNumber(integer: Int(self.contourRight!.totalPixels!) + Int(self.differenceRight!.totalPixels!)))!)
        
        let hueLowFields = String(format: "hue, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.hueLow!),
                                (Int(self.contourLeft!.lowTotal!) == 0) ? 0 : Int(self.contourLeft!.hueLow!)/Int(self.contourLeft!.lowTotal!),
                                Int(self.contourRight!.hueLow!),
                                (Int(self.contourRight!.lowTotal!) == 0) ? 0 : Int(self.contourRight!.hueLow!)/Int(self.contourRight!.lowTotal!),
                                Int(self.differenceLeft!.hueLow!),
                                (Int(self.differenceLeft!.lowTotal!) == 0) ? 0 : Int(self.differenceLeft!.hueLow!)/Int(self.differenceLeft!.lowTotal!),
                                Int(self.differenceRight!.hueLow!),
                                (Int(self.differenceRight!.lowTotal!) == 0) ? 0 : Int(self.differenceRight!.hueLow!)/Int(self.differenceRight!.lowTotal!),
                                Int(self.contourLeft!.hueLow!) + Int(self.differenceLeft!.hueLow!),
                                (Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!) == 0) ? 0 : (Int(self.contourLeft!.hueLow!) + Int(self.differenceLeft!.hueLow!))/(Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!)),
                                Int(self.contourRight!.hueLow!) + Int(self.differenceRight!.hueLow!),
                                (Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!) == 0) ? 0 : (Int(self.contourRight!.hueLow!) + Int(self.differenceRight!.hueLow!))/(Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!))
        )
        
        let satLowFields = String(format: "sat, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.satLow!),
                                  (Int(self.contourLeft!.lowTotal!) == 0) ? 0 : Int(self.contourLeft!.satLow!)/Int(self.contourLeft!.lowTotal!),
                                  Int(self.contourRight!.satLow!),
                                  (Int(self.contourRight!.lowTotal!) == 0) ? 0 : Int(self.contourRight!.satLow!)/Int(self.contourRight!.lowTotal!),
                                  Int(self.differenceLeft!.satLow!),
                                  (Int(self.differenceLeft!.lowTotal!) == 0) ? 0 : Int(self.differenceLeft!.satLow!)/Int(self.differenceLeft!.lowTotal!),
                                  Int(self.differenceRight!.satLow!),
                                  (Int(self.differenceRight!.lowTotal!) == 0) ? 0 : Int(self.differenceRight!.satLow!)/Int(self.differenceRight!.lowTotal!),
                                  Int(self.contourLeft!.satLow!) + Int(self.differenceLeft!.satLow!),
                                  (Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!) == 0) ? 0 : (Int(self.contourLeft!.satLow!) + Int(self.differenceLeft!.satLow!))/(Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!)),
                                  Int(self.contourRight!.satLow!) + Int(self.differenceRight!.satLow!),
                                  (Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!) == 0) ? 0 : (Int(self.contourRight!.satLow!) + Int(self.differenceRight!.satLow!))/(Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!))
        )
        
        
        let valLowFields = String(format: "val, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.valLow!),
                                  (Int(self.contourLeft!.lowTotal!) == 0) ? 0 : Int(self.contourLeft!.valLow!)/Int(self.contourLeft!.lowTotal!),
                                  Int(self.contourRight!.valLow!),
                                  (Int(self.contourRight!.lowTotal!) == 0) ? 0 : Int(self.contourRight!.valLow!)/Int(self.contourRight!.lowTotal!),
                                  Int(self.differenceLeft!.valLow!),
                                  (Int(self.differenceLeft!.lowTotal!) == 0) ? 0 : Int(self.differenceLeft!.valLow!)/Int(self.differenceLeft!.lowTotal!),
                                  Int(self.differenceRight!.valLow!),
                                  (Int(self.differenceRight!.lowTotal!) == 0) ? 0 : Int(self.differenceRight!.valLow!)/Int(self.differenceRight!.lowTotal!),
                                  Int(self.contourLeft!.valLow!) + Int(self.differenceLeft!.valLow!),
                                  (Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!) == 0) ? 0 : (Int(self.contourLeft!.valLow!) + Int(self.differenceLeft!.valLow!))/(Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!)),
                                  Int(self.contourRight!.valLow!) + Int(self.differenceRight!.valLow!),
                                  (Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!) == 0) ? 0 : (Int(self.contourRight!.valLow!) + Int(self.differenceRight!.valLow!))/(Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!))
        )
        
        let hsvLowTotalPixelFields = String(format: "total pixels, %@, N/A, %@, N/A, %@, N/A, %@, N/A, %@, N/A, %@, N/A\n"
            , numberFormatter.stringFromNumber(self.contourLeft!.lowTotal!)!
            , numberFormatter.stringFromNumber(self.contourRight!.lowTotal!)!
            , numberFormatter.stringFromNumber(self.differenceLeft!.lowTotal!)!
            , numberFormatter.stringFromNumber(self.differenceRight!.lowTotal!)!
            , numberFormatter.stringFromNumber(NSNumber(integer: Int(self.contourLeft!.lowTotal!) + Int(self.differenceLeft!.lowTotal!)))!
            , numberFormatter.stringFromNumber(NSNumber(integer: Int(self.contourRight!.lowTotal!) + Int(self.differenceRight!.lowTotal!)))!)
        
        let hueHighFields = String(format: "hue, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.hueHigh!),
                                  (Int(self.contourLeft!.highTotal!) == 0) ? 0 : Int(self.contourLeft!.hueHigh!)/Int(self.contourLeft!.highTotal!),
                                  Int(self.contourRight!.hueHigh!),
                                  (Int(self.contourRight!.highTotal!) == 0) ? 0 : Int(self.contourRight!.hueHigh!)/Int(self.contourRight!.highTotal!),
                                  Int(self.differenceLeft!.hueHigh!),
                                  (Int(self.differenceLeft!.highTotal!) == 0) ? 0 : Int(self.differenceLeft!.hueHigh!)/Int(self.differenceLeft!.highTotal!),
                                  Int(self.differenceRight!.hueHigh!),
                                  (Int(self.differenceRight!.highTotal!) == 0) ? 0 : Int(self.differenceRight!.hueHigh!)/Int(self.differenceRight!.highTotal!),
                                  Int(self.contourLeft!.hueHigh!) + Int(self.differenceLeft!.hueHigh!),
                                  (Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!) == 0) ? 0 : (Int(self.contourLeft!.hueHigh!) + Int(self.differenceLeft!.hueHigh!))/(Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!)),
                                  Int(self.contourRight!.hueHigh!) + Int(self.differenceRight!.hueHigh!),
                                  (Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!) == 0) ? 0 : (Int(self.contourRight!.hueHigh!) + Int(self.differenceRight!.hueHigh!))/(Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!))
        )
        
        
        let satHighFields = String(format: "sat, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.satHigh!),
                                   (Int(self.contourLeft!.highTotal!) == 0) ? 0 : Int(self.contourLeft!.satHigh!)/Int(self.contourLeft!.highTotal!),
                                   Int(self.contourRight!.satHigh!),
                                   (Int(self.contourRight!.highTotal!) == 0) ? 0 : Int(self.contourRight!.satHigh!)/Int(self.contourRight!.highTotal!),
                                   Int(self.differenceLeft!.satHigh!),
                                   (Int(self.differenceLeft!.highTotal!) == 0) ? 0 : Int(self.differenceLeft!.satHigh!)/Int(self.differenceLeft!.highTotal!),
                                   Int(self.differenceRight!.satHigh!),
                                   (Int(self.differenceRight!.highTotal!) == 0) ? 0 : Int(self.differenceRight!.satHigh!)/Int(self.differenceRight!.highTotal!),
                                   Int(self.contourLeft!.satHigh!) + Int(self.differenceLeft!.satHigh!),
                                   (Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!) == 0) ? 0 : (Int(self.contourLeft!.satHigh!) + Int(self.differenceLeft!.satHigh!))/(Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!)),
                                   Int(self.contourRight!.satHigh!) + Int(self.differenceRight!.satHigh!),
                                   (Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!) == 0) ? 0 : (Int(self.contourRight!.satHigh!) + Int(self.differenceRight!.satHigh!))/(Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!))
        )
        
        let valHighFields = String(format: "val, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n", Int(self.contourLeft!.valHigh!),
                                   (Int(self.contourLeft!.highTotal!) == 0) ? 0 : Int(self.contourLeft!.valHigh!)/Int(self.contourLeft!.highTotal!),
                                   Int(self.contourRight!.valHigh!),
                                   (Int(self.contourRight!.highTotal!) == 0) ? 0 : Int(self.contourRight!.valHigh!)/Int(self.contourRight!.highTotal!),
                                   Int(self.differenceLeft!.valHigh!),
                                   (Int(self.differenceLeft!.highTotal!) == 0) ? 0 : Int(self.differenceLeft!.valHigh!)/Int(self.differenceLeft!.highTotal!),
                                   Int(self.differenceRight!.valHigh!),
                                   (Int(self.differenceRight!.highTotal!) == 0) ? 0 : Int(self.differenceRight!.valHigh!)/Int(self.differenceRight!.highTotal!),
                                   Int(self.contourLeft!.valHigh!) + Int(self.differenceLeft!.valHigh!),
                                   (Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!) == 0) ? 0 : (Int(self.contourLeft!.valHigh!) + Int(self.differenceLeft!.valHigh!))/(Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!)),
                                   Int(self.contourRight!.valHigh!) + Int(self.differenceRight!.valHigh!),
                                   (Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!) == 0) ? 0 : (Int(self.contourRight!.valHigh!) + Int(self.differenceRight!.valHigh!))/(Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!))
        )
        
        let hsvHighTotalPixelFields = String(format: "total pixels, %@, N/A, %@, N/A, %@, N/A, %@, N/A, %@, N/A, %@, N/A\n"
            , numberFormatter.stringFromNumber(self.contourLeft!.highTotal!)!
            , numberFormatter.stringFromNumber(self.contourRight!.highTotal!)!
            , numberFormatter.stringFromNumber(self.differenceLeft!.highTotal!)!
            , numberFormatter.stringFromNumber(self.differenceRight!.highTotal!)!
            , numberFormatter.stringFromNumber(NSNumber(integer: Int(self.contourLeft!.highTotal!) + Int(self.differenceLeft!.highTotal!)))!
            , numberFormatter.stringFromNumber(NSNumber(integer: Int(self.contourRight!.highTotal!) + Int(self.differenceRight!.highTotal!)))!)
        
        return String(format: "%@%@%@%@%@,Hue 0..30:\n%@%@%@%@,Hue 31..179:\n%@%@%@%@", csvHeader, redFields, greenFields, blueFields, rgbTotalPixelFields, hueLowFields, satLowFields, valLowFields, hsvLowTotalPixelFields, hueHighFields, satHighFields, valHighFields, hsvHighTotalPixelFields)
    }
    
    func saveToCVS() throws -> NSURL {
        let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = documentsDirectory.URLByAppendingPathComponent(String(format: "%@-%@.csv", self.lastName!, self.firstName!))
        try self.toCSV().writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
        return fileURL
    }
    
    class func saveToCVS(moc: NSManagedObjectContext) throws -> NSURL {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        //let fileURL = documentsDirectory.URLByAppendingPathComponent(String(format: "%@.csv", dateFormatter.stringFromDate(NSDate())))
        let fileURL = documentsDirectory.URLByAppendingPathComponent("AllPatients.csv")
        let header = String(format: "%@\n", dateFormatter.stringFromDate(NSDate()))
        try header.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
        let fetchRequest = NSFetchRequest(entityName: "Patient")
        if let patients = try moc.executeFetchRequest(fetchRequest) as? [Patient] {
            for patient in patients {
                try patient.toCSV().appendToURL(fileURL)
            }
        }
        return fileURL
    }
    
    class func imageURL(moc: NSManagedObjectContext) throws -> [NSURL] {
        var imageURLArray:[NSURL] = []
        let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fetchRequest = NSFetchRequest(entityName: "Patient")
        if let patients = try moc.executeFetchRequest(fetchRequest) as? [Patient] {
            for patient in patients {
                let fileURL = documentsDirectory.URLByAppendingPathComponent(patient.lastName! + "-" + patient.firstName! + ".jpg")
                imageURLArray.append(fileURL)
            }
        }
        return imageURLArray
    }
    
    func imageURL() -> NSURL {
        let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        return documentsDirectory.URLByAppendingPathComponent(self.lastName! + "-" + self.firstName! + ".jpg")
    }

    
}
