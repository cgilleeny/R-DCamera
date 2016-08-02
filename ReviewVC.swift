//
//  ReviewVC.swift
//  testCamera
//
//  Created by Caroline Gilleeny on 6/15/16.
//  Copyright © 2016 Bruce Ng. All rights reserved.
//

import UIKit
import CoreData

class ReviewVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    
    var moc: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
    var fetchedResultsController: NSFetchedResultsController?

    //var csvURL:NSURL?
    
    /*
    lazy var activityItems: [AnyObject] = {
        var items: [AnyObject] = []
        do {
            items = try Patient.imageURL(self.moc)
            if self.csvURL != nil {
                items.append(self.csvURL!)
            }
        } catch {
            print("Error with image URL array")
        }
        /*
        var items: [AnyObject] = []

        if self.csvURL != nil {
            items.append(self.csvURL!)
        }
        */
        return items

    }()
    
    lazy var activityViewController:UIActivityViewController = {
        let activityVC = UIActivityViewController(activityItems: self.activityItems, applicationActivities: [])
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop,
                                            UIActivityTypeAddToReadingList,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypePrint,
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypePostToFacebook,
                                            UIActivityTypeSaveToCameraRoll]
        
        //activityVC.popoverPresentationController?.barButtonItem = self.actionBarButtonItem
        activityVC.popoverPresentationController?.delegate = self
        return activityVC
    }()
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest(entityName: "Patient")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch {
            print("poop")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionBarButtonItemHandler(sender: UIBarButtonItem) {
        var activityItems: [AnyObject] = []
        do {
            activityItems = try Patient.imageURL(self.moc)
            if let csvURL = try Patient.saveToCVS(self.moc) as NSURL? {
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

    // MARK: - tableView
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func numberOfSectionsInTableView
        (tableView: UITableView) -> Int {
        if let frController = fetchedResultsController as NSFetchedResultsController? {
            return frController.sections!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let frController = fetchedResultsController as NSFetchedResultsController? {
            let sectionInfo = frController.sections![section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PatientCell") as UITableViewCell!
        if let frController = fetchedResultsController as NSFetchedResultsController? {
            let patient = frController.objectAtIndexPath(indexPath) as! Patient
            cell.textLabel?.text = String(format: "%@,%@", patient.lastName!, patient.firstName!)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-YY"
            cell.detailTextLabel?.text = dateFormatter.stringFromDate(patient.dateOfBirth!)
            
            let documentsDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let fileURL = documentsDirectory.URLByAppendingPathComponent(patient.lastName! + "-" + patient.firstName! + ".jpg")

            if let imageData = NSData(contentsOfURL : fileURL) as NSData? {
                cell.imageView!.image =  UIImage(data: imageData)
            }
        }
        return cell
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let frController = fetchedResultsController as NSFetchedResultsController? {
                let patient = frController.objectAtIndexPath(indexPath) as! Patient
                moc.deleteObject(patient)
            }
        }
    }

    
    // MARK: - FetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PatientDetail" {
            if let patientDetailVC = segue.destinationViewController as? PatientDetailVC {
                if let frController = fetchedResultsController as NSFetchedResultsController? {
                    if let indexPath = self.tableView.indexPathForSelectedRow as NSIndexPath? {
                        patientDetailVC.patient = frController.objectAtIndexPath(indexPath) as! Patient
                    }
                }
            }
        }
    }
   

}
