//
//  AddTopicTableViewController.swift
//  pPoll
//
//  Created by Nath on 8/14/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit

class AddTopicTableViewController : UITableViewController {
    var topics = Model.sharedInstance.topics
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
        return topics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CircularTableViewCell") as! CircularTableViewCell
        
        let topic = topics[indexPath.row]
        cell.circularLabel.text = topic.name
        cell.circularImage.image = topic.photo
        cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
        cell.circularImage.clipsToBounds = true

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
        for j in 0...topics.count {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: 0)) {
                cell.accessoryType = .None
            }
        }
    }
    
    @IBAction func handleAddTopic(sender: AnyObject) {
        groupCreationController?.selectedTopics = checked
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func handleCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
