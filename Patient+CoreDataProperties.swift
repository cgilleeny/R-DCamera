//
//  Patient+CoreDataProperties.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/24/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Patient {

    @NSManaged var dateOfBirth: NSDate?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var luminance: NSNumber?
    @NSManaged var iso: NSNumber?
    @NSManaged var contourLeft: PupilROI?
    @NSManaged var contourRight: PupilROI?
    @NSManaged var differenceLeft: PupilROI?
    @NSManaged var differenceRight: PupilROI?

}
