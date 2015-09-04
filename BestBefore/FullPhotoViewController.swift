//
//  FullPhotoViewController.swift
//  BestBefore
//
//  Created by Jase Kurasz on 5/27/15.
//  Copyright (c) 2015 Jase Kurasz. All rights reserved.
//

import UIKit

class FullPhotoViewController: UIViewController {
    var photoURL: String!
    var date: String!

    @IBOutlet weak var fullPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let noPhotoURL = NSURL(fileURLWithPath: noImage)?.absoluteString!
        if self.photoURL != noPhotoURL {
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docDir: NSString = paths.objectAtIndex(0) as! NSString
            
            let path: NSString = docDir.stringByAppendingString(self.photoURL)
            self.fullPhoto.image = UIImage(contentsOfFile: path as String)
            
        }else{
            self.fullPhoto.image = UIImage(named: noImage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
