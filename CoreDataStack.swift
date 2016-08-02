//
//  CoreDataStack.swift
//  AssetProPlus
//
//  Created by Caroline Gilleeny on 8/14/15.
//  Copyright (c) 2015 aValanche eVantage. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    let context: NSManagedObjectContext
    let psc: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let store: NSPersistentStore?
    
    class func applicationDocumentsDirectory() -> NSURL {
        return try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    
    init() {
        let bundle = NSBundle.mainBundle()
        let modeURL = bundle.URLForResource("testCamera", withExtension: "momd")
        model = NSManagedObjectModel(contentsOfURL: modeURL!)!
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        context.mergePolicy =
        NSOverwriteMergePolicy
        let documentsURL = CoreDataStack.applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("testCamera")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        } catch  {
            print("Error adding persistent store")
            abort()
        }
        
        
    }
    
    func saveContent() {
        if context.hasChanges {
            do {
                try context.save()
            } catch  {
                print("Could not save context")
                abort()
            }
        }
    }
    


}
