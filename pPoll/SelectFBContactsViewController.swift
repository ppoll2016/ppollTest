//
//  SelectFBContactsViewController.swift
//  pPoll
//
//  Created by Nath on 10/16/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SelectFBContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    lazy var ref = FIRDatabase.database().reference()
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    var contacts = [Contact]()
    var filteredContacts = [Contact]()
    var selectedContacts = [Bool]()
    var selectedUids = [String]()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var showSearchResults  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = FBSDKAccessToken.currentAccessToken() {
            print("Has Facebook login")
            fetchUserFriends()

        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    func fetchUserFriends() {
        let para = ["fields":"email, id, name, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me/friends", parameters: para).startWithCompletionHandler({ (connection, result, error) in
            if error != nil {
                print(error.localizedDescription)
                return
            }
            print(result)
            print("finish feching user's friend")
            for friendDictionary in result["data"] as! [NSDictionary] {
                let uid = friendDictionary["id"] as? String
                let name = friendDictionary["name"] as? String
                
                self.ref.child("Accounts").queryOrderedByChild("FaceBookID").queryStartingAtValue(uid).queryEndingAtValue(uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    // Account found
                    if snapshot.childrenCount != 0 {
                        for (key, account) in snapshot.value as! [String: [String : AnyObject]] {
                            print(account["username"] as! String + ": " + uid!)
                            let account = Account(uid: key, snapshot: account)
                            let tableContact = Contact(name: name!, number: account.phoneNumber, uid: key)

                            if !self.model.accounts.contains(account) {
                                self.model.addAccount(account)
                                //add profile to account
                                self.ref.child("Profiles").child(account.uid).observeSingleEventOfType(.Value, withBlock: {
                                    (snapshotProfile) in
                                    if let p = snapshotProfile.value as? [String : AnyObject]{
                                        let profile = Profile(snapshot: p)
                                        self.model.addProfile(account, profile: profile)
                                        // get profile image
                                        self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                                            profile.photo = image!
                                            print(image!)
                                            print(account.uid)
                                            print("retrieve from normal question ===\(image)")
                                            self.model.addProfileImageCore(account.uid, image: image!)
                                            
                                            tableContact.photo = image!
                                            self.contacts.append(tableContact)
                                            
                                            if !self.selectedUids.contains(account.uid) {
                                                self.selectedContacts.append(false)
                                            }
                                            else {
                                                self.selectedContacts.append(true)
                                            }
                                            
                                            self.tableView.reloadData()
                                        })
                                    }
                                    else if let picture = friendDictionary["picture"]?["data"]?!["url"] as? String {
                                        //                    print(name)
                                        //                    print(picture)
                                        let url = NSURL(string: picture)
                                        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                                            if error != nil {
                                                print(error)
                                                return
                                            }
                                            let image = UIImage(data: data!)
                                            tableContact.photo = image
                                            print("finsih grabing facebook user profile image")
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self.contacts.append(tableContact)
                                                
                                                if !self.selectedUids.contains(account.uid) {
                                                    self.selectedContacts.append(false)
                                                }
                                                else {
                                                    self.selectedContacts.append(true)
                                                }
                                                
                                                self.tableView.reloadData()
                                            })
                                        }).resume()
                                    }
                                    else if let picture = friendDictionary["picture"]?["data"]?!["url"] as? String {
                                        //                    print(name)
                                        //                    print(picture)
                                        let url = NSURL(string: picture)
                                        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                                            if error != nil {
                                                print(error)
                                                return
                                            }
                                            let image = UIImage(data: data!)
                                            tableContact.photo = image
                                            print("finsih grabing facebook user profile image")
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                self.contacts.append(tableContact)
                                                
                                                if !self.selectedUids.contains(account.uid) {
                                                    self.selectedContacts.append(false)
                                                }
                                                else {
                                                    self.selectedContacts.append(true)
                                                }
                                                
                                                self.tableView.reloadData()
                                            })
                                        }).resume()
                                    }
                                })
                            }
                            else {
                                let account = self.model.findAccountByUid(key)
                                let tableContact = Contact(name: name!, number: account!.phoneNumber, uid: key)
                                tableContact.photo = account?.profile.photo
                                self.contacts .append(tableContact)
                                
                                if !self.selectedUids.contains(account!.uid) {
                                    self.selectedContacts.append(false)
                                }
                                else {
                                    self.selectedContacts.append(true)
                                }
                                
                                self.tableView.reloadData()
                            }
                        }
                    }
                })
            }
        })
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredContacts = contacts.filter({ (contact : Contact) -> Bool in
            contact.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || contact.number.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
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
            return filteredContacts.count
        }
        else {
            return contacts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Member Cell") as! CircularTableViewCell
        
        let contact: Contact
        if showSearchResults {
            contact = filteredContacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        
        cell.circularLabel.text = contact.name
        
        cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
        cell.circularImage.clipsToBounds = true
        
        if contact.photo != nil {
            cell.circularImage.image = contact.photo
        }
        else {
            cell.circularImage.image = UIImage(named: "placeholder")
        }
        
        var index = indexPath.row
        
        if showSearchResults {
            index = contacts.indexOf({ $0.number == contact.number })!
        }
        
        if selectedContacts[index] {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if showSearchResults {
            let index = contacts.indexOf({ $0.number == filteredContacts[indexPath.row].number })
            
            if selectedContacts[index!] {
                selectedContacts[index!] = false
            }
            else {
                selectedContacts[index!] = true
            }
        }
        else {
            if selectedContacts[indexPath.row] {
                selectedContacts[indexPath.row] = false
            }
            else {
                selectedContacts[indexPath.row] = true
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func inviteContacts(sender: AnyObject) {
        performSegueWithIdentifier("unwindToQuestionCreation", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let questionCreationVC = segue.destinationViewController as! QuestionCreationViewController
        var selectedCount = 0
        
        for index in 0...selectedContacts.count - 1 {
            let contact = contacts[index]

            if selectedContacts[index] {
                if !questionCreationVC.contacts.contains({ if $0.uid != nil { return $0.uid == contact.uid } else { return false }}) {
                    questionCreationVC.contacts.append(contact)
                    questionCreationVC.selectedFBUids.append(contact.uid)
                }
                
                selectedCount = selectedCount + 1
            }
            else {
                if selectedUids.contains(contact.uid) {
                    questionCreationVC.contacts.removeAtIndex(questionCreationVC.contacts.indexOf({ $0.uid == contact.uid })!)
                    questionCreationVC.selectedFBUids.removeAtIndex(questionCreationVC.selectedFBUids.indexOf({ $0 == contact.uid })!)
                }
            }
        }
        
        questionCreationVC.smInviteCount.text = "\(selectedCount) invited"
        
        questionCreationVC.selectedSMContacts = selectedContacts
        
        questionCreationVC.group = nil
        questionCreationVC.sendToGroupLabel.text = ""
    }
}
