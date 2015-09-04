//
//  InventoryTableViewController.swift
//  BestBefore
//
//  Created by Jase Kurasz on 5/27/15.
//  Copyright (c) 2015 Jase Kurasz. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class InventoryTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var totalEntries: Int = 0

    @IBOutlet var inventoryTable: UITableView!
    @IBOutlet weak var btnGrocery: UIButton!
    
    //remove all the cells
    @IBAction func btnClear(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        var results: NSArray = managedContext.executeFetchRequest(fetchRequest, error: nil)!
        
        for item: AnyObject in results as [AnyObject] {
            let noPhotoURL = NSURL(fileURLWithPath: noImage)?.absoluteString!
            let itemPhotoURL = item.valueForKey("photo")as! String
            let itemIconURL = item.valueForKey("icon")as! String
            if itemPhotoURL != noPhotoURL {
                let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let docDir: NSString = paths.objectAtIndex(0) as! NSString
            
                let fileManager: NSFileManager = NSFileManager.defaultManager()
                fileManager.removeItemAtPath(docDir.stringByAppendingString(itemPhotoURL), error: nil)
                fileManager.removeItemAtPath(docDir.stringByAppendingString(itemIconURL), error: nil)
            }
            managedContext.deleteObject(item as! NSManagedObject)
        }
        
        managedContext.save(nil)
        totalEntries = 0
        inventoryTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        totalEntries = managedContext.countForFetchRequest(fetchRequest, error: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return totalEntries
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell") as! UITableViewCell
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        var results: NSArray = managedContext.executeFetchRequest(fetchRequest, error: nil)!
        var foodItem = results[indexPath.row] as! NSManagedObject
        let dateString = foodItem.valueForKey("date") as? String
        let dateLable: UILabel = cell.viewWithTag(101) as! UILabel
        dateLable.text = "Use By: \(dateString!)"
        let iconPhoto: UIImageView = cell.viewWithTag(100) as! UIImageView
        let noPhotoString = NSURL.fileURLWithPath(noImage)?.absoluteString!
        let foodData = results[indexPath.row] as! NSObject
        if foodData.valueForKey("icon") as? String != noPhotoString {
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docDir: NSString = paths.objectAtIndex(0) as! NSString
            let path: NSString = docDir.stringByAppendingString(foodData.valueForKey("icon") as! String)
            iconPhoto.image = UIImage(contentsOfFile: path as String)
        }else{
            iconPhoto.image = UIImage(named: noImage)
        }
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell") as! UITableViewCell
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "FoodItem")
        var results: NSArray = managedContext.executeFetchRequest(fetchRequest, error: nil)!
        
        let noPhotoURL = NSURL(fileURLWithPath: noImage)?.absoluteString!
        let itemPhotoURL = results[indexPath.row].valueForKey("photo") as! String
        let itemIconURL = results[indexPath.row].valueForKey("icon") as! String
        if itemPhotoURL != noPhotoURL {
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docDir: NSString = paths.objectAtIndex(0) as! NSString
            
            let fileManager: NSFileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtPath(docDir.stringByAppendingString(itemPhotoURL), error: nil)
            fileManager.removeItemAtPath(docDir.stringByAppendingString(itemIconURL), error: nil)
        }
        
        managedContext.deleteObject(results[indexPath.row] as! NSManagedObject)
        managedContext.save(nil)
        totalEntries--
        inventoryTable.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFullPhoto" {
            let controller: FullPhotoViewController = segue.destinationViewController as! FullPhotoViewController
            let indexPath: NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName: "FoodItem")
            var results: NSArray = managedContext.executeFetchRequest(fetchRequest, error: nil)!
            
            let foodData = results[indexPath.row] as! NSObject
            
            controller.photoURL = foodData.valueForKey("photo") as! String
            controller.date = foodData.valueForKey("date") as! String
        }
    }

}
