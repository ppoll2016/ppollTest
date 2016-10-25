//
//  ResultViewController.swift
//  pPoll
//
//  Created by James McKay on 7/09/2016.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit
import Firebase
import Contacts

class ResultViewController: UIViewController {
    lazy var ref = FIRDatabase.database().reference()
    var responsesRef: FIRDatabaseReference!
    
    let contactStore = CNContactStore()
    var cnContacts: [CNContact]!
    var contacts = [Contact]()
    var responseContacts = [Contact]()
    
    //Model
    let model: Model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    var question : Question!
    
    var currentUser: Account!
    
    // Firebase References
    
    //wont need the group, grou member, make ans and respon ref more general
    var accountsRef: FIRDatabaseReference!
    var answersRef: FIRDatabaseReference!
    var accountContacts: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    
    var refHandle: FIRDatabaseHandle!
    
    //UI Linking
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var leftAnswerButton: UIButton!
    @IBOutlet weak var leftResultLabel: UILabel!
    @IBOutlet weak var rightAnswerButton: UIButton!
    @IBOutlet weak var rightResultLabel: UILabel!
    @IBOutlet weak var photoLabel2: UILabel!
    @IBOutlet weak var photoLabel1: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var northContainerView: UIView!
    @IBOutlet weak var southContainerView: UIView!
    
    @IBOutlet weak var questionContentHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign the database references
        accountsRef = ref.child("Accounts")
        answersRef = ref.child("Answers")
        accountContacts = ref.child("AccountContacts").child(question.owner)
        profileRef = ref.child("Profiles")
        
        leftAnswerButton.layer.cornerRadius = leftAnswerButton.frame.size.width / 2
        leftAnswerButton.clipsToBounds = true
        
        rightAnswerButton.layer.cornerRadius = rightAnswerButton.frame.size.width / 2
        rightAnswerButton.clipsToBounds = true
        
        // Add the gesture recognisers
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
        leftSwipe.direction = .Left
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        currentUser = model.user
        
        if question.content.characters.count <= 51 {
            questionContentHeight.constant = questionContentHeight.constant + 10
        }
        
        populateUserFields()
    }
    
    func populateUserFields() {
        questionLabel.text = question.content
        
        // add account to model if it is not in model
        if self.model.findAccountByUid(question.owner) == nil {
            self.accountsRef.child(question.owner).observeSingleEventOfType(.Value, withBlock: { (snapshotAccount) in
                let account = Account(uid: self.question.owner, snapshot: snapshotAccount.value as! [String : AnyObject])
                self.model.addAccount(account)
                
                //add profile to account
                self.profileRef.child(account.uid).observeSingleEventOfType(.Value, withBlock: {
                    (snapshotProfile) in
                    let profile = Profile(snapshot: snapshotProfile.value as! [String : AnyObject])
                    self.model.addProfile(account, profile: profile)
                    // get profile image
                    self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                        profile.photo = image!
                        
                        self.userNameLabel.text = account.username
                        
                        //newly added
                        if account.profile != nil {
                            self.groupImageView.image = account.profile.photo
                        }
                        self.groupImageView.layer.cornerRadius = self.groupImageView.frame.size.width / 2
                        self.groupImageView.clipsToBounds = true
                    })
                })
                
                self.userNameLabel.text = account.username
                
                //newly added
                if account.profile != nil {
                    self.groupImageView.image = account.profile.photo
                }
                self.groupImageView.layer.cornerRadius = self.groupImageView.frame.size.width / 2
                self.groupImageView.clipsToBounds = true
            })
        }
        else {
            let account = model.findAccountByUid(question.owner)
            self.userNameLabel.text = account!.username
            
            //newly added
            if account!.profile != nil {
                self.groupImageView.image = account!.profile.photo
            }
            self.groupImageView.layer.cornerRadius = self.groupImageView.frame.size.width / 2
            self.groupImageView.clipsToBounds = true
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        responsesRef.removeAllObservers()
    }
    
    //Used for getting responses
    func addResponseListeners(reference: FIRDatabaseReference) {
        // Adding a response
        reference.observeEventType(.ChildAdded, withBlock: { (snapshot) in let groupQResponseSnapshot = snapshot.value as! [String: AnyObject]
            let owner = snapshot.key
            let response = Response(owner: owner, snapshot: groupQResponseSnapshot)
            self.addResponseToView(response)
        })
            
        // Removing a response
        reference.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
            print("Removing user " + snapshot.key + " response to question")
            self.model.removeResponseFromQuestion(self.question, owner: snapshot.key)
            self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
            self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
            
            self.reloadResultsDisplay()
        })
        
        // Changing a response
        reference.observeEventType(.ChildChanged, withBlock: { (snapshot) in let groupQResponseSnapshot = snapshot.value as! [String: AnyObject]
            print("User " + snapshot.key + " has changed their response to question")
            let response = Response(owner: snapshot.key, snapshot: groupQResponseSnapshot)
            self.addResponseToView(response)
            self.model.updateResponseFromUser(self.question, response: response)
            self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
            self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
            self.setResponseNoToZero()
        })
    }
    
    func addResponseToView(response: Response) {
        
    }
    
    func setResponseNoToZero() {
        firebaseModel.setResponseToZero(question, currentUID: model.user.uid)
    }
    
    func getAnswers(completion: (Bool) -> ()) {
        // Add question answer
        self.answersRef.child(question.ID).observeEventType(.ChildAdded, withBlock: { (snapshot) in let groupQAnswerSnapshot = snapshot.value as! [String: AnyObject]
            print("Adding an answer to question " + self.question.content)
            if groupQAnswerSnapshot["text"] as? String != nil {
                let answer = Answer(id: snapshot.key, text: groupQAnswerSnapshot["text"] as! String)
                
                if groupQAnswerSnapshot["photo"] != nil {
                    self.question.answers.append(answer)
                    self.model.addAnswerToQuestion(self.question, answer: answer)
                    answer.photo = UIImage(named: "placeholder")
                    
                    self.firebaseModel.getQuestionAnswerPhoto(self.question.ID, imagenamed: snapshot.key, image: { (image) in
                        answer.photo = image
                        self.updateAnswerPhotos()
                    })
                }
                else {
                    self.question.answers.append(answer)
                    self.model.addAnswerToQuestion(self.question, answer: answer)
                }
            }
            
            if self.question.answers.count == 2 {
                self.addDataPoint()
                completion(true)
            }
        })
    }
    
    func reloadResultsDisplay() {
        
    }
    
    func addDataPoint() {
        
    }
    
    func updateAnswerPhotos() {
        if question.answers.count != 1 {
            leftAnswerButton.setBackgroundImage(question.answers[0].photo, forState: .Normal)
            rightAnswerButton.setBackgroundImage(question.answers[1].photo, forState: .Normal)
        }
    }
    
    //Actions
    @IBAction func leftAnswerAction(sender: AnyObject) {
        updateResponse(0)
    }
    
    @IBAction func rightAnswerAction(sender: AnyObject) {
        updateResponse(1)
    }
    
    func updateResponse(index: Int) {
        let response: Response
        var newResponse = false
        
        if question.responses.contains({ $0.owner == currentUser.uid }) {
            response = question.responses[question.responses.indexOf({ $0.owner == currentUser.uid })!]
            if response.answer != question.answers[index].id {
                response.answer = question.answers[index].id
                newResponse = true
            }
        }
        else {
            if question.responses.contains({ $0.owner == currentUser.phoneNumber }) {
                firebaseModel.updatePhoneResponse(question.ID, number: currentUser.phoneNumber)
            }
            
            let currentDate = NSDate()
            let calender = NSCalendar.currentCalendar()
            let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
            
            let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
            
            response = Response(owner: model.user.uid, answer: question.answers[index].id, date: date)
            question.responses.append(response)
            newResponse = true
        }
        
        leftResultLabel.text = leftQuestionPercentage(question)
        rightResultLabel.text = rightQuestionPercentage(question)
        
        // Update response in firebase
        if newResponse {
            updateResponses(response)
            reloadResultsDisplay()
        }
    }
    
    func updateResponses(response: Response) {
        
    }
    
    func leftQuestionPercentage(question:Question)->String{
        return percentString(0)
    }
    
    func rightQuestionPercentage(question:Question)->String{
        return percentString(1)
    }
    
    func percentString(index: Int) -> String {
        let total = Double(question.responses.count)
        var responseCounter: Double = 0
        var qPercentage: Double = 0
        for response in  question.responses{
            if(response.answer == question.answers[index].id){
                responseCounter += 1
            }
        }
        
        updateResponseCounter(index, responseCount: responseCounter)
        
        if total != 0 {
            qPercentage = responseCounter/total*100
        }
        
        let qPercentageString = String(Int(qPercentage))+"%"
        return qPercentageString
    }
    
    func updateResponseCounter(index: Int, responseCount: Double) {
        
    }
    
    func loadQuestionFields(){
        // add account to model if it is not in model
        if self.model.findAccountByUid(question.owner) == nil {
            self.accountsRef.child(question.owner).observeSingleEventOfType(.Value, withBlock: { (snapshotAccount) in
                let account = Account(uid: self.question.owner, snapshot: snapshotAccount.value as! [String : AnyObject])
                self.model.addAccount(account)
                
                //add profile to account
                self.profileRef.child(account.uid).observeSingleEventOfType(.Value, withBlock: {
                    (snapshotProfile) in
                    let profile = Profile(snapshot: snapshotProfile.value as! [String : AnyObject])
                    self.model.addProfile(account, profile: profile)
                    // get profile image
                    self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                        profile.photo = image!
                        self.populateFields(account)
                    })
                })
                
                self.populateFields(account)
            })
        }
        else {
            let account = model.findAccountByUid(question.owner)
            populateFields(account!)
        }
    }
    
    func populateFields(account: Account) {
        userNameLabel.text = account.username
        questionLabel.text = question.content
        // leftAnswerButton.setTitle(question.answers[0].text, forState: .Normal)
        //rightAnswerButton.setTitle(question.answers[1].text, forState: .Normal)
        
        
        //newly added
        if account.profile != nil {
            groupImageView.image = account.profile.photo
        }
        groupImageView.layer.cornerRadius = groupImageView.frame.size.width / 2
        groupImageView.clipsToBounds = true
        
        //IF TEXT AND PHOTO PRESENT
        if(question.answers[0].photo != nil && question.answers[0].text != nil){
            leftAnswerButton.setBackgroundImage(question.answers[0].photo, forState: .Normal)
            leftAnswerButton.setTitle("", forState: .Normal);
            photoLabel1.text = question.answers[0].text
            
            //IF PHOTO PRESENT AND TEXT IS NOT PRESENT
        } else if(question.answers[0].photo != nil && question.answers[0].text == nil){
            leftAnswerButton.setBackgroundImage(question.answers[0].photo, forState: .Normal)
            leftAnswerButton.setTitle("", forState: .Normal);
            
            
        }
            //IF  TEXT ONLY
        else if (question.answers[0].photo == nil && question.answers[0].text != nil){
            leftAnswerButton.setTitle(question.answers[0].text, forState: .Normal)
        }
        //~~~~~~~
        
        //IF TEXT AND PHOTO PRESENT
        if(question.answers[1].photo != nil && question.answers[1].text != nil){
            rightAnswerButton.setBackgroundImage(question.answers[1].photo, forState: .Normal)
            rightAnswerButton.setTitle("", forState: .Normal);
            photoLabel2.text = question.answers[1].text
            
            //IF PHOTO PRESENT AND TEXT IS NOT PRESENT
        } else if(question.answers[1].photo != nil && question.answers[1].text == nil){
            rightAnswerButton.setBackgroundImage(question.answers[1].photo, forState: .Normal)
            rightAnswerButton.setTitle("", forState: .Normal);
            
            
        }
            //IF  TEXT ONLY
        else if (question.answers[1].photo == nil && question.answers[1].text != nil){
            rightAnswerButton.setTitle(question.answers[1].text, forState: .Normal)
        }
        leftResultLabel.text = leftQuestionPercentage(question)
        rightResultLabel.text = rightQuestionPercentage(question)
    }
    
    func checkForAccounts(completion: (Bool) -> ()) {
        var contactsCount = cnContacts.count
        var count = 1
        
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
                                let account = Account(uid: key, snapshot: account)
                                
                                if !self.model.accounts.contains(account) {
                                    self.model.accounts.append(account)
                                }
                                
                                let name = contact.givenName + " " + contact.familyName
                                let tableContact = Contact(name: name, number: number.stringValue, uid: key)
                                self.contacts.append(tableContact)
                            }
                        }
                            // Account not found
                        else {
                            print("Account not found")
                            let name = contact.givenName + " " + contact.familyName
                            let tableContact = Contact(name: name, number: number.stringValue)
                            self.contacts.append(tableContact)
                        }
                        
                        if count == contactsCount {
                            completion(true)
                        }
                        else {
                            count = count + 1
                        }
                    })
                    
                    mobileFound = true
                }
            }
            
            if !mobileFound {
                self.cnContacts.removeAtIndex(self.cnContacts.indexOf(contact)!)
                contactsCount = contactsCount - 1
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
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        print("swipe recognised")
        if sender.direction == .Right {
            updateResponse(1)
        }
        else {
            updateResponse(0)
        }
    }
}