//
//  CreateGroupViewController.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Contacts
import Firebase

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    lazy var ref = FIRDatabase.database().reference()
    
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    let imagePicker = UIImagePickerController()
    
    let contactStore = CNContactStore()
    
    var showSearchResults = false
    var cnContacts: [CNContact]!
    var contacts = [Contact]()
    var filteredContacts = [Contact]()
    var selectedContacts = [Bool]()
    var currentInviteNo = 0
    
    var group: GroupContacts!
    var extraGroupContacts = [Contact]()
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupImageButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Edit Group
        if group != nil {
            groupName.text = group.name
            groupImageButton.setBackgroundImage(group.photo, forState: .Normal)
            
            button.setTitle("Edit", forState: .Normal)
            self.title = "Edit Group"
        }
        
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                // Get Phone Contacts
                self.cnContacts = self.getContacts()
                
                if self.group != nil {
                    self.extraGroupContacts = self.group.contacts
                }
                
                // Check phone numbers for accounts/ Remove all contacts that don't have a mobile number
                self.checkForAccounts()
            }
        }
        
        groupImageButton.layer.cornerRadius = groupImageButton.frame.size.width / 2
        groupImageButton.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker.delegate = self
        
        searchBar.delegate = self
        groupName.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func checkForAccounts() {
        for contact in self.cnContacts {
            var mobileFound = false
            for phoneNo in contact.phoneNumbers {
                // Check if any of the numbers are mobile numbers
                if phoneNo.label == CNLabelPhoneNumberMobile || phoneNo.label == CNLabelPhoneNumberiPhone {
                    let number = phoneNo.value as! CNPhoneNumber
                    print(contact.givenName + " " + contact.familyName + ": " + number.stringValue)
                    
                    // Check if there is an account
                    self.ref.child("Accounts").queryOrderedByChild("phone").queryStartingAtValue(number.stringValue).queryEndingAtValue(number.stringValue).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        // Account found
                        if snapshot.childrenCount != 0 {
                            for (key, account) in snapshot.value as! [String: [String : AnyObject]] {
                                print(account["username"] as! String + ": " + number.stringValue)
                                let name = contact.givenName + " " + contact.familyName
                                let tableContact = Contact(name: name, number: number.stringValue, uid: key)
                                
                                if self.group != nil {
                                    self.ref.child("AccountGroups").child(key).child(self.group.ID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let value = snapshot.value as? Bool
                                        if value != nil {
                                            self.selectedContacts.append(true)
                                        }
                                        else {
                                            self.selectedContacts.append(false)
                                        }
                                        
                                        self.contacts.append(tableContact)
                                        self.tableView.reloadData()
                                    })
                                }
                                else {
                                    self.contacts.append(tableContact)
                                    self.selectedContacts.append(false)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                            // Account not found
                        else {
                            print("Account not found")
                            let name = contact.givenName + " " + contact.familyName
                            let tableContact = Contact(name: name, number: number.stringValue)
                            
                            if self.group != nil {
                                self.ref.child("AccountGroups").child(tableContact.number).child(self.group.ID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let value = snapshot.value as? Bool
                                    if value != nil {
                                        self.selectedContacts.append(true)
                                    }
                                    else {
                                        self.selectedContacts.append(false)
                                    }
                                    
                                    self.contacts.append(tableContact)
                                    self.tableView.reloadData()
                                })
                            }
                            else {
                                self.contacts.append(tableContact)
                                self.selectedContacts.append(false)
                                self.tableView.reloadData()
                            }
                        }
                    })
                    
                    mobileFound = true
                }
            }
            
            if !mobileFound {
                self.cnContacts.removeAtIndex(self.cnContacts.indexOf(contact)!)
            }
        }
    }
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    func getContacts() -> [CNContact] {
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "pPoll", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredContacts = contacts.filter({ (contact : Contact) -> Bool in contact.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || contact.number.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Contacts Cell", forIndexPath: indexPath) as! CircularTableViewCell
        
        var contact : Contact
        
        if showSearchResults {
            contact = filteredContacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        
        cell.circularImage.image = UIImage(named: "placeholder")
        
        cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
        cell.circularImage.clipsToBounds = true
        
        cell.circularLabel.text = contact.name
        
        cell.selectionStyle = .None
        
        var index = indexPath.row
        
        if showSearchResults {
            if contact.uid != nil {
                index = contacts.indexOf({
                    if $0.uid != nil {
                        return $0.uid == contact.uid
                    }
                    return false
                })!
            }
            else {
                index = contacts.indexOf({ $0.number == contact.number })!
            }
        }
        
        if selectedContacts[index] {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
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
            if indexPath.row < selectedContacts.count {
                if selectedContacts[indexPath.row] {
                    selectedContacts[indexPath.row] = false
                }
                else {
                    selectedContacts[indexPath.row] = true
                }
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        if groupName.text != "" {
            let name = groupName.text
            let photo = groupImageButton.currentBackgroundImage
            
            var newContacts = [Contact]()
            
            // Add the owner to the list of members
            let userContact = Contact(name: "", number: "", uid: model.user.uid)
            newContacts.append(userContact)
            
            for index in 0...contacts.count - 1 {
                if selectedContacts[index] {
                    newContacts.append(contacts[index])
                }
            }
            
            var newGroup: GroupContacts
            
            if group != nil {
                newGroup = GroupContacts(ID: group.ID, name: name!, owner: model.user.uid)
            }
            else {
                newGroup = GroupContacts(ID: "", name: name!, owner: model.user.uid)
            }
            
            newGroup.photo = photo
            newGroup.contacts = newContacts
            
            firebaseModel.createGroupContacts(newGroup)
            performSegueWithIdentifier("unwindToQuestionCreation", sender: self)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    @IBAction func selectGroupImage(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            groupImageButton.setBackgroundImage(pickedImage, forState: .Normal)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        performSegueWithIdentifier("unwindToQuestionCreation", sender: self)
    }
}

