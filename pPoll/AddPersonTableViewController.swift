//
//  AddPersonTableViewController.swift
//  pPoll
//
//  Created by Nath on 8/13/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit

class AddPersonTableViewController : UITableViewController {
    var accounts = Model.sharedInstance.accounts
    
    weak var groupCreationController : GroupCreationController?
    var checked : [Bool]!
    
    override func viewDidLoad() {
        navigationController?.navigationBar.hidden = false
        
        setChecks()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CircularTableViewCell") as! CircularTableViewCell
        
        let account = accounts[indexPath.row]
        cell.circularLabel.text = account.username
        
        if account.profile != nil {
            cell.circularImage.image = UIImage(named: account.profile.photo)
            cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
            cell.circularImage.clipsToBounds = true
        }
        else {
            cell.circularImage.image = UIImage(named: "placeholder")
            cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
            cell.circularImage.clipsToBounds = true
        }
        
        // Cell Properties
        cell.selectionStyle = .None
        
        if !checked[indexPath.row] {
            cell.accessoryType = .None
        } else if checked[indexPath.row] {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            } else {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }    
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func setChecks() {
        for j in 0...accounts.count {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: 0)) {
                cell.accessoryType = .None
            }
        }
    }
    
    @IBAction func handleAddPerson(sender: AnyObject) {
        groupCreationController?.selectedAccounts = checked
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func handleCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
