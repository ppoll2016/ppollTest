//
//  SelectGroupViewController.swift
//  pPoll
//
//  Created by Nath on 10/4/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase

class SelectGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    lazy var ref = FIRDatabase.database().reference()
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    var groups = [GroupContacts]()
    var filteredGroups = [GroupContacts]()
    
    var editIndex: Int!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase References
    var accountsRef: FIRDatabaseReference!
    var accountGroupRef: FIRDatabaseReference!
    var groupRef: FIRDatabaseReference!
    
    var groupsRefHandles = [String: FIRDatabaseHandle]()
    
    var showSearchResults  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        // Assign Firebase References
        let uid = FIRAuth.auth()?.currentUser?.uid
        accountsRef = ref.child("Accounts")
        accountGroupRef = ref.child("AccountGroups").child(uid!)
        groupRef = ref.child("Groups")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // User group added
        accountGroupRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            print ("User is part of group " + snapshot.key)
            self.createGroupListeners(snapshot.key)
        })
        
        // User group removed
        accountGroupRef.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
            print ("User is no longer part of group " + snapshot.key)
            self.groups.removeAtIndex(self.groups.indexOf({ $0.ID == snapshot.key })!)
            self.model.removeGroup(snapshot.key)
            self.tableView.reloadData()
            
            if let refHandle = self.groupsRefHandles[snapshot.key] {
                self.ref.child("Groups").child(snapshot.key).removeObserverWithHandle(refHandle)
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        accountGroupRef.removeAllObservers()
        
        // Remove Group References
        for (key,refHandle) in groupsRefHandles {
            groupRef.child(key).removeObserverWithHandle(refHandle)
        }
    }
    
    func createGroupListeners(ID: String) {
        // Get group
        let refHandle = groupRef.child(ID).observeEventType(.Value, withBlock: { (snapshot) in let groupSnapshot = snapshot.value as? [String: AnyObject]
            if groupSnapshot != nil {
                let group = GroupContacts(ID: ID, snapShot: groupSnapshot!)
                
                if self.groups.contains({ $0.ID == ID }) {
                    print("Group " + (groupSnapshot!["name"] as! String) + " has been updated in the model")
                    self.tableView.reloadData()
                }
                else {
                    print("Group " + (groupSnapshot!["name"] as! String) + " has been added to the model")
                    self.groups.append(group)
                    self.tableView.reloadData()
                    
                    // Get Group Image
                    self.firebaseModel.getGroupImage(group.ID, image: { (image) in
                        group.photo = image
                        self.tableView.reloadData()
                    })
                }
            }
        })
        
        groupsRefHandles[ID] = refHandle
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredGroups = groups.filter({ (group : GroupContacts) -> Bool in
            group.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        
        if searchText != "" {
            showSearchResults = true
            tableView.reloadData()
        }
        else {
            showSearchResults = false
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        showSearchResults = true
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResults {
            return filteredGroups.count
        }
        else {
            return groups.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Group Cell", forIndexPath: indexPath) as! CircularTableViewCell
        
        // Configure the cell
        let group : GroupContacts
        
        if showSearchResults {
            group = filteredGroups[indexPath.row]
        }
        else {
            group = groups[indexPath.row]
        }
        
        cell.circularImage.image = group.photo
        cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
        cell.circularImage.clipsToBounds = true
        cell.circularLabel.text = group.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit", handler: { action, indexpath in
            self.editIndex = indexPath.row
            self.editGroup()
        })
        editAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Leave", handler: { action, indexpath in self.leaveGroup(indexPath.row)
        })
        
        return[deleteAction, editAction]
    }
    
    func editGroup() {
        performSegueWithIdentifier("Edit Group", sender: self)
    }
    
    func leaveGroup(index: Int) {
        var group: GroupContacts
        
        if showSearchResults {
            group = filteredGroups[index]
        }
        else {
            group = groups[index]
        }
        
        if group.owner == model.user.uid {
            let alert = UIAlertController(title: "Leave " + group.name + "?", message: "Are you sure you would like to leave " + group.name + "?\n If you leave the group it will be disbanded", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
                self.firebaseModel.deleteGroup(group)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                print("Cancel Leave Group")
            }))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Leave " + group.name + "?", message: "Are you sure you would like to leave " + group.name + "?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
                self.firebaseModel.leaveGroup(group.ID, uid: self.model.user.uid)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                print("Cancel Leave Group")
            }))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Edit Group" {
            let createGroupVC = segue.destinationViewController as! CreateGroupViewController
            
            if showSearchResults {
                let group = filteredGroups[editIndex]
                createGroupVC.group = group
            }
            else {
                let group = groups[editIndex]
                createGroupVC.group = group
            }
        }
        else {
            let questionCreationVC = segue.destinationViewController as! QuestionCreationViewController
            
            if showSearchResults {
                let group = filteredGroups[tableView.indexPathForSelectedRow!.row]
                questionCreationVC.group = group
                questionCreationVC.sendToGroupLabel.text = group.name
            }
            else {
                let group = groups[tableView.indexPathForSelectedRow!.row]
                questionCreationVC.group = group
                questionCreationVC.sendToGroupLabel.text = group.name
            }
        }
    }
}
