//
//  ViewController.swift
//  pPoll
//
//  Created by Nath on 8/13/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        let groupCreationController = self.storyboard!.instantiateViewControllerWithIdentifier("GroupCreationController") as! GroupCreationController
        let navController = UINavigationController(rootViewController: groupCreationController)
        self.presentViewController(navController, animated: false, completion: nil)
    }
    
    @IBAction func joinGroup(sender: AnyObject) {
        let joinGroupsController = self.storyboard!.instantiateViewControllerWithIdentifier("JoinGroupsController") as! JoinGroupsTableViewController
        let navController = UINavigationController(rootViewController: joinGroupsController)
        self.presentViewController(navController, animated: false, completion: nil)
    }
}

