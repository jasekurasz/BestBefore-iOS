//
//  EnterFoodItemViewController.swift
//  BestBefore
//
//  Created by Jase Kurasz on 5/27/15.
//  Copyright (c) 2015 Jase Kurasz. All rights reserved.
//

import UIKit
import CoreData

let noImage = "No_image_available.jpg"

class EnterFoodItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var photoEnlarged: String!
    var photoIcon: String!
    let userCalendar = NSCalendar.currentCalendar()
    var localNotifications: UILocalNotification = UILocalNotification()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var photoPreview: UIImageView!
    
    @IBAction func btnSave(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("FoodItem", inManagedObjectContext:managedContext)
        let foodItem = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yyy"
        let dateString = dateFormat.stringFromDate(datePicker.date)
        foodItem.setValue(dateString, forKey: "date")
        
        //set up notification to show a day before selected date
        let periodComponents = NSDateComponents()
        periodComponents.day = -1
        let dayBefore = userCalendar.dateByAddingComponents(periodComponents, toDate: datePicker.date, options: nil)
        localNotifications.alertAction = "REMINDER"
        localNotifications.alertBody = "You have a food item expiring tomorrow!"
        localNotifications.fireDate = dayBefore
        UIApplication.sharedApplication().scheduleLocalNotification(localNotifications)
        
        //set the photo preview
        if self.photoEnlarged == nil {
            let URL = NSURL(fileURLWithPath: noImage)?.absoluteString
            foodItem.setValue(URL, forKey: "photo")
            foodItem.setValue(URL, forKey: "icon")
        }else{
            foodItem.setValue(self.photoEnlarged, forKey: "photo")
            foodItem.setValue(self.photoIcon, forKey: "icon")
        }
        managedContext.save(nil)
        resetParams()
    }
    
    @IBAction func btnPhotoSelect(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        if sender.tag == 1 {
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        }
        else { //Will not work on Simluator because it has no camera
            picker.sourceType = UIImagePickerControllerSourceType.Camera
        }
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetParams()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        var newImage: UIImage = scalePhoto(image, size: CGSize(width: screenSize.width, height: screenSize.height))
        self.photoPreview.image = newImage
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir: NSString = paths.objectAtIndex(0) as! NSString
        
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now: NSDate = NSDate(timeIntervalSinceNow: 0)
        let date: NSString = dateFormat.stringFromDate(now)
        
        //Name for the enlarged picture
        self.photoEnlarged = NSString(format: "/%@.png", date) as String
        
        //save the enlarged picture
        let pathEnlarged: NSString = docDir.stringByAppendingString(self.photoEnlarged)
        let picEnlargedData: NSData = UIImagePNGRepresentation(newImage)
        picEnlargedData.writeToFile(pathEnlarged as String, atomically: true)
        
        let iconImage: UIImage = scalePhoto(newImage, size: CGSize(width: 100, height: 100))
        self.photoIcon = NSString(format: "/%@_icon.p as Stringng", date) as String
        let pathIcon: NSString = docDir.stringByAppendingString(self.photoIcon)
        let picIconData: NSData = UIImagePNGRepresentation(iconImage)
        picIconData.writeToFile(pathIcon as String, atomically: true)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //scale the photo so it fits within the contraints of the screen size
    func scalePhoto(image: UIImage, size: CGSize) -> UIImage {
        let scale: CGFloat = max(size.width/image.size.width, size.height/image.size.height)
        let width: CGFloat = image.size.width * scale
        let height: CGFloat = image.size.height * scale
        let imageRect: CGRect = CGRectMake((size.width-width)/2.0, (size.height-height)/2.0, width, height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.drawInRect(imageRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resetParams() {
        self.photoEnlarged = nil
        self.photoPreview.image = UIImage(named: noImage)
    }

}
