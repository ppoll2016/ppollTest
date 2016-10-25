//
//  AddPhoneContactViewController.swift
//  pPoll
//
//  Created by Nath on 9/29/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Contacts
import Firebase

class AddPhoneContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    lazy var ref = FIRDatabase.database().reference()
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    let contactStore = CNContactStore()
    var cnContacts: [CNContact]!
    var contacts = [Contact]()
    var filteredContacts = [Contact]()
    var selectedContacts = [Bool]()
    var selectedNumbers = [String]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var showSearchResults  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                // Get Phone Contacts
                self.cnContacts = self.getContacts()
                
                // Check phone numbers for accounts/ Remove all contacts that don't have a mobile number
                self.checkForAccounts()
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForAccounts() {
        for contact in self.cnContacts {
            var mobileFound = false
            for phoneNo in contact.phoneNumbers {
                // Check if any of the numbers are mobile numbers
                if phoneNo.label == CNLabelPhoneNumberMobile || phoneNo.label == CNLabelPhoneNumberiPhone {
                    let number = phoneNo.value as! CNPhoneNumber
                    var numberTrim = number.stringValue.trimPhoneNumber()
                    
                    if numberTrim.substringToIndex(numberTrim.startIndex.successor()) == "0" {
                        numberTrim = numberTrim.stringByReplacingCharactersInRange(numberTrim.startIndex..<numberTrim.startIndex.successor(), withString: "+61")
                    }
                    
                    print(contact.givenName + " " + contact.familyName + ": " + numberTrim)
                    
                    // Check if there is an account
                    self.ref.child("Accounts").queryOrderedByChild("phone").queryStartingAtValue(numberTrim).queryEndingAtValue(numberTrim).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        // Account found
                        if snapshot.childrenCount != 0 {
                            for (key, account) in snapshot.value as! [String: [String : AnyObject]] {
                                print(account["username"] as! String + ": " + numberTrim)
                                let account = Account(uid: key, snapshot: account)
                                
                                if !self.model.accounts.contains(account) {
                                    self.model.accounts.append(account)
                                }
                                
                                if !self.selectedNumbers.contains(account.phoneNumber) {
                                    self.selectedContacts.append(false)
                                }
                                else {
                                    self.selectedContacts.append(true)
                                }
                                
                                let name = contact.givenName + " " + contact.familyName
                                let tableContact = Contact(name: name, number: numberTrim, uid: key)
                                
                                self.firebaseModel.getProfileImage(key, image: { (image) in
                                    if image != UIImage(named: "placeholder") {
                                        tableContact.photo = image
                                    }
                                    else if contact.imageData != nil {
                                        tableContact.photo = UIImage(data: contact.imageData!)
                                    }
                                    
                                    self.contacts.append(tableContact)
                                    self.tableView.reloadData()
                                })
                            }
                        }
                            // Account not found
                        else {
                            print("Account not found")
                            let name = contact.givenName + " " + contact.familyName
                            let tableContact = Contact(name: name, number: numberTrim)
                            self.contacts.append(tableContact)

                            if !self.selectedNumbers.contains(numberTrim) {
                                self.selectedContacts.append(false)
                            }
                            else {
                                self.selectedContacts.append(true)
                            }
                            
                            self.tableView.reloadData()
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
                if !questionCreationVC.contacts.contains({ $0.number ==  contact.number }) {
                    questionCreationVC.contacts.append(contact)
                    questionCreationVC.selectedPCNumbers.append(contact.number)
                }
                
                selectedCount = selectedCount + 1
            }
            else {                
                if selectedNumbers.contains(contact.number) {
                    questionCreationVC.contacts.removeAtIndex(questionCreationVC.contacts.indexOf({ $0.number == contact.number })!)
                    questionCreationVC.selectedPCNumbers.removeAtIndex(questionCreationVC.selectedPCNumbers.indexOf({ $0 == contact.number })!)
                }
            }
        }
        
        questionCreationVC.pcInvitedCount.text = "\(selectedCount) invited"
        
        questionCreationVC.selectedPCContacts = selectedContacts
        
        questionCreationVC.group = nil
        questionCreationVC.sendToGroupLabel.text = ""
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
            CNContactThumbnailImageDataKey,CNContactImageDataKey]
        
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
}

extension String {
    func trimPhoneNumber() -> String {
        return String(self.characters.filter({ String($0).rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789")) != nil }))
    }
}