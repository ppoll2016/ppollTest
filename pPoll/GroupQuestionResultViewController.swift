//
//  GroupQuestionResultViewController.swift
//  pPoll
//
//  Created by James McKay on 28/09/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class GroupQuestionResultViewController: ResultViewController, UITableViewDataSource,UITableViewDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    //    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var answeredActivityTable: UITableView!
    var filteredResponses = [[Response]]()
    var filteredContacts = [[Contact]]()
    
    
    
    var sections = ["Yes","No","TBA"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        northContainerView.layer.cornerRadius = 10
        northContainerView.clipsToBounds = true
        southContainerView.layer.cornerRadius = 10
        southContainerView.clipsToBounds = true
        
        responsesRef = ref.child("Responses").child(question.ID)
        //                sections = [self.question.answers[0].text,"nah","test"]
        for _ in 0...2 {
            filteredResponses.append([Response]())
            filteredContacts.append([Contact]())
        }

        loadTableData()
        answeredActivityTable.delegate=self
        answeredActivityTable.dataSource=self
        answeredActivityTable.allowsSelection = false
        print("Content Size:" + String(question.content.characters.count))
    }
    
    override func viewDidAppear(animated: Bool) {
        if question.answers.count == 0 {
            getAnswers({ _ in
                self.sections[0] = self.question.answers[0].text
                self.sections[1] = self.question.answers[1].text
                self.loadResponses()
            })
        }
        else {
            sections[0] = question.answers[0].text
            sections[1] = question.answers[1].text
            
            if model.questionMembers[question.ID] != nil {
                responseContacts = model.questionMembers[question.ID]!
                reloadResultsDisplay()
            }
            loadResponses()
        }
    }
    
    func loadResponses() {
        loadQuestionFields()
        
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                // Get Phone Contacts
                self.cnContacts = self.getContacts()
                
                self.requestForAccess { (accessGranted) -> Void in
                    if accessGranted {
                        // Get Phone Contacts
                        self.cnContacts = self.getContacts()
                        
                        // Check phone numbers for accounts/ Remove all contacts that don't have a mobile number
                        self.checkForAccounts({ _ in
                            self.addResponseListeners(self.responsesRef)
                        })
                    }
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  sections[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResponses[section].count
        
    }
    
    override func addResponseToView(response: Response) {
        if !self.model.accounts.contains({ $0.uid == response.owner }) {
            self.accountsRef.child(response.owner).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let accountSnapshot = snapshot.value as? [String: AnyObject]
                // Account found
                if accountSnapshot != nil {
                    print("Account retrieved")
                    let account = Account(uid: snapshot.key, snapshot: accountSnapshot!)
                    
                    self.model.addAccount(account)
                    
                    self.profileRef.child(account.uid).observeSingleEventOfType(.Value, withBlock: {
                        (snapshotProfile) in
                        if let p = snapshotProfile.value as? [String : AnyObject]{
                            let profile = Profile(snapshot: p)
                            self.model.addProfile(account, profile: profile)
                            // get profile image
                            self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                                profile.photo = image!
                                print(image!)
                                print(account.uid)
                                print("retrieve from result view ===\(image)")
                                self.model.addProfileImageCore(account.uid, image: image!)
                                self.reloadResultsDisplay()
                            })
                        }
                    })
                    
                    var facebookID = accountSnapshot!["FaceBookID"] as? String
                    
                    if facebookID == nil {
                        facebookID = ""
                    }
                    
                    self.findAccountContact(account, facebookID: facebookID!, contact: { (contact) in
                        self.checkAccountResponseContact(contact)
                        self.checkResponse(response)
                    })
                }
                // No Account
                else {
                    self.findNonAccountContact(response.owner, contact: { (contact) in
                        self.checkNonAccountResponseContact(contact)
                        self.checkResponse(response)
                    })
                }
            })
        }
        else {
            let account = model.findAccountByUid(response.owner)
            
            if account?.phoneNumber == "" || response.owner == self.question.owner {
                let contact = Contact(name: (account?.username)!, number: (account?.phoneNumber)!, uid: (account?.uid)!)
                self.checkAccountResponseContact(contact)
                self.checkResponse(response)
            }
            else {
                var facebookID = ""
                if account?.phoneNumber == "" {
                    facebookID = " "
                }
                
                self.findAccountContact(account!, facebookID: facebookID, contact: { (contact) in
                    self.checkAccountResponseContact(contact)
                    self.checkResponse(response)
                })
            }
        }
    }

    func findAccountContact(account: Account, facebookID:String, contact: (Contact) -> ()) {
        // Check phone contacts
        var phoneContact: Contact?
        for contact in self.contacts {
            if account.phoneNumber == contact.number {
                phoneContact = Contact(name: contact.name, number: account.phoneNumber, uid: account.uid)
                break
            }
        }
        
        if phoneContact != nil {
            contact(phoneContact!)
        }
        
        // Check question owners phone contacts
        self.accountContacts.observeSingleEventOfType(.Value, withBlock: { (snapshot) in let contactsSnapshot = snapshot.value as? [String: AnyObject]
            if contactsSnapshot != nil {
                if facebookID != "" {
                    let name = contactsSnapshot![account.uid] as! String
                    
                    let contactFB = Contact(name: name, number: account.phoneNumber, uid: account.uid)
                    contact(contactFB)
                }
                else {
                    let name = contactsSnapshot![account.phoneNumber] as! String
                    
                    if account.phoneNumber == name {
                        let contactAcc = Contact(name: account.username, number: account.phoneNumber, uid: account.uid)
                        contact(contactAcc)
                    }
                    else {
                        let contactAcc = Contact(name: name, number: account.phoneNumber, uid: account.uid)
                        contact(contactAcc)
                    }
                }
            }
        })
    }
    
    func findNonAccountContact(owner: String, contact: (Contact) -> ()) {
        // Check phone contacts
        var phoneContact: Contact?
        for contact in self.contacts {
            if owner == contact.number {
                phoneContact = contact
                break
            }
        }
        
        if phoneContact != nil {
            contact(phoneContact!)
        }
        
        self.accountContacts.observeSingleEventOfType(.Value, withBlock: { (snapshot) in let contactsSnapshot = snapshot.value as? [String: AnyObject]
            if contactsSnapshot != nil {
                let name = contactsSnapshot![owner] as! String
                
                let contactAcc = Contact(name: name, number: owner)
                contact(contactAcc)
            }
        })
    }
    
    func checkAccountResponseContact(contact: Contact) {
        if !self.responseContacts.contains({ $0.uid == contact.uid }) {
            self.responseContacts.append(contact)
            
            if self.model.questionMembers[self.question.ID] == nil {
                self.model.questionMembers[self.question.ID] = [Contact]()
                self.model.questionMembers[self.question.ID]?.append(contact)
            }
            else {
                self.model.questionMembers[self.question.ID]?.append(contact)
            }
            
            self.reloadResultsDisplay()
        }
    }
    
    func checkNonAccountResponseContact(contact: Contact) {
        if !self.responseContacts.contains({ $0.number == contact.number }) {
            self.responseContacts.append(contact)
            
            if self.model.questionMembers[self.question.ID] == nil {
                self.model.questionMembers[self.question.ID] = [Contact]()
                self.model.questionMembers[self.question.ID]?.append(contact)
            }
            else {
                self.model.questionMembers[self.question.ID]?.append(contact)
            }
            
            self.reloadResultsDisplay()
        }
    }
    
    func checkResponse(response: Response) {
        if !self.question.responses.contains(response) {
            self.model.addResponseToQuestion(self.question, response: response)
            self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
            self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
            
            self.reloadResultsDisplay()
        }
        else {
            let oldResponse = self.question.responses[self.question.responses.indexOf(response)!]
            print("Old Response ID:\(oldResponse.answer), New Response ID:\(response.answer)")
            
            if oldResponse.answer != response.answer {
                self.model.updateResponseFromUser(self.question, response: response)
                
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                self.reloadResultsDisplay()
            }
        }
    }
    
    override func updateResponses(response: Response) {
        firebaseModel.updateGroupQuestionResponse(question, response: response, currentUID: model.user.uid)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = answeredActivityTable.dequeueReusableCellWithIdentifier("TBACell") as! AnswerPageCell
            cell.resultsVC = self
            
            cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
            cell.circularImage.clipsToBounds = true

            let response = filteredResponses[indexPath.section][indexPath.row]

            if response.answer == "-1" {
                cell.circularLabel.text = ""
                cell.textLabel?.text = "There are no responses for answer " + sections[indexPath.section]
                cell.circularImage.image = nil
            }
            else {
                cell.textLabel?.text = ""
                
                if filteredContacts[indexPath.section].count > indexPath.row {
                    let contact = filteredContacts[indexPath.section][indexPath.row]
                    cell.circularLabel.text = contact.name
                    
                    if contact.number != ""{
                        cell.number = contact.number
                    }
                    
                }
                
                if model.accounts.contains({ $0.uid == filteredResponses[indexPath.section][indexPath.row].owner }) {
                    let account = model.accounts[model.accounts.indexOf({ $0.uid == filteredResponses[indexPath.section][indexPath.row].owner })!]
                    
                    if account.profile != nil {
                        cell.circularImage.image = account.profile.photo
                    }
                    else {
                        cell.circularImage.image = UIImage(named: "placeholder")
                    }
                }
            }
            
            return cell
        }
            
        else{
            let cell = answeredActivityTable.dequeueReusableCellWithIdentifier("AnswerPageCell") as! CircularTableViewCell
            
            cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
            cell.circularImage.clipsToBounds = true
            
            let response = filteredResponses[indexPath.section][indexPath.row]
            
            if response.answer == "-1" {
                cell.circularLabel.text = ""
                cell.textLabel?.text = "There are no responses for answer " + sections[indexPath.section]
                cell.circularImage.image = nil
            }
            else {
                cell.textLabel?.text = ""
                
                if filteredContacts[indexPath.section].count > indexPath.row {
                    let contact = filteredContacts[indexPath.section][indexPath.row]
                    cell.circularLabel.text = contact.name
                }
                
                
                if model.accounts.contains({ $0.uid == filteredResponses[indexPath.section][indexPath.row].owner }) {
                    let account = model.accounts[model.accounts.indexOf({ $0.uid == filteredResponses[indexPath.section][indexPath.row].owner })!]
                    
                    if account.profile != nil {
                        cell.circularImage.image = account.profile.photo
                    }
                    else {
                        cell.circularImage.image = UIImage(named: "placeholder")
                    }
                }
            }
            
            return cell
        }
    }
    
    //TODO: move method to model
    func filterResponses(response: Response, id: String) -> Bool {
        return response.answer == id
    }
    
    override func reloadResultsDisplay() {
        loadTableData()
    }
    
    
    func loadTableData(){
        for index in 0...2 {
            filteredResponses[index].removeAll()
            filteredContacts[index].removeAll()
        }
        
        for response in question.responses{
            switch response.answer {
            case question.answers[0].id:
                filteredResponses[0].append(response)
                
                for contact in responseContacts {
                    if contact.uid != nil {
                        if contact.uid == response.owner {
                            filteredContacts[0].append(contact)
                        }
                        else if contact.number == response.owner {
                            filteredContacts[0].append(contact)
                        }
                    }
                    else if contact.number == response.owner {
                        filteredContacts[0].append(contact)
                    }
                }
                break
            case question.answers[1].id:
                filteredResponses[1].append(response)
                
                for contact in responseContacts {
                    if contact.uid != nil {
                        if contact.uid == response.owner {
                            filteredContacts[1].append(contact)
                        }
                        else if contact.number == response.owner {
                            filteredContacts[1].append(contact)
                        }
                    }
                    else if contact.number == response.owner {
                        filteredContacts[1].append(contact)
                    }
                }
                break
            default:
                filteredResponses[2].append(response)
                
                for contact in responseContacts {
                    if contact.uid != nil {
                        if contact.uid == response.owner {
                            filteredContacts[2].append(contact)
                        }
                        else if contact.number == response.owner {
                            filteredContacts[2].append(contact)
                        }
                    }
                    else if contact.number == response.owner {
                        filteredContacts[2].append(contact)
                    }
                }
                break
            }
        }
        
        
        if filteredResponses[0].count == 0 {
            filteredResponses[0].append(Response(owner: "", answer: "-1", date: ""))
        }
        else if filteredResponses[1].count == 0{
            filteredResponses[1].append(Response(owner: "", answer: "-1", date: ""))
        }
        else if filteredResponses[2].count == 0{
            filteredResponses[2].append(Response(owner: "", answer: "-1", date: ""))
        }
        answeredActivityTable.reloadData()
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 83/255, green: 196/255, blue: 195/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        header.alpha = 0.5 //make the header transparent
    }
    
    func presentMessageThing(number: String) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [number]
        composeVC.body = "Hi, you have a question on Ppoll that you haven't answered"
        self.presentViewController(composeVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
