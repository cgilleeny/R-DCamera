//
//  PupilROI+CoreDataProperties.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 7/25/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PupilROI {

    @NSManaged var blue: NSNumber?
    @NSManaged var green: NSNumber?
    @NSManaged var luminance: NSNumber?
    @NSManaged var red: NSNumber?
    @NSManaged var totalPixels: NSNumber?
    @NSManaged var hueLow: NSNumber?
    @NSManaged var satLow: NSNumber?
    @NSManaged var valLow: NSNumber?
    @NSManaged var lowTotal: NSNumber?
    @NSManaged var highTotal: NSNumber?
    @NSManaged var hueHigh: NSNumber?
    @NSManaged var satHigh: NSNumber?
    @NSManaged var valHigh: NSNumber?

}
