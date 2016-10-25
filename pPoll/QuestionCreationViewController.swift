//
//  QuestionCreationViewController.swift
//  pPoll
//
//  Created by Nath on 9/28/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class QuestionCreationViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    lazy var ref = FIRDatabase.database().reference()
    
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    var recentKeys = [String]()
    var group: GroupContacts!
    var contacts = [Contact]()
    var selectedPCContacts = [Bool]()
    var selectedPCNumbers = [String]()
    var selectedFBUids = [String]()

    var selectedSMContacts = [Bool]()
    var question: Question!
    
    let answerOneImagePicker = UIImagePickerController()
    let answerTwoImagePicker = UIImagePickerController()
    
    @IBOutlet weak var questionContent: UITextField!
    @IBOutlet weak var answerOneButton: UIButton!
    @IBOutlet weak var answerOneContent: UITextField!
    @IBOutlet weak var answerTwoButton: UIButton!
    @IBOutlet weak var answerTwoContent: UITextField!
    @IBOutlet weak var manualEntryTextfield: UITextField!
    
    @IBOutlet weak var pcInvitedCount: UILabel!
    @IBOutlet weak var smInviteCount: UILabel!
    @IBOutlet weak var createGroupLabel: UILabel!
    
    @IBOutlet weak var sendToGroupLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionContent.delegate = self
        answerOneContent.delegate = self
        answerTwoContent.delegate = self
        manualEntryTextfield.delegate = self
        
        answerOneButton.layer.cornerRadius = answerOneButton.frame.size.width / 2
        answerOneButton.clipsToBounds = true
        
        answerTwoButton.layer.cornerRadius = answerTwoButton.frame.size.width / 2
        answerTwoButton.clipsToBounds = true
        
        answerOneImagePicker.delegate = self
        answerTwoImagePicker.delegate = self
        
        
        
        LoadingOverlay.shared.hideOverlayView()
        setUserInteraction(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        recentKeys.removeAll()
        setUserInteraction(true)
        addProfileImageToNavigationBar()
    }
    
    var image: UIImage = UIImage(named: "p logo")! {
        didSet{
        }
    }
    
    func addProfileImageToNavigationBar(){
        let imageHolder: UIImage = UIImage(named: "p logo")!
        var image = imageHolder
       // let image = model.user.profile.photo
        if let photo: UIImage = model.user?.profile?.photo {
            image = photo
        }
        
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 40, 40)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true
        button.layer.cornerRadius = CGRectGetHeight(button.bounds)/2.0
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(self.rightNavBarItemAction), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem?.customView = button
    }
    
    func rightNavBarItemAction() {
        performSegueWithIdentifier("GoToProfileFromQuestionPage", sender: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createQuestion(sender: AnyObject) {
        //        let messageVC = MFMessageComposeViewController()
        //
        //        messageVC.body = "Just invited you to a question on pPoll! Check it out on the app store if you don't already have it"
        //        var numbers = [String]()
        //
        //        for contact in contacts {
        //            numbers.append(contact.number)
        //        }
        //
        //        messageVC.recipients = numbers
        //        messageVC.messageComposeDelegate = self
        //
        //        presentViewController(messageVC, animated: false, completion: nil)
        createQuestion()
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case MessageComposeResultCancelled:
            print("Message cancelled")
            dismissViewControllerAnimated(true, completion: nil)
            createQuestion()
            break
        case MessageComposeResultFailed:
            print("Message failed")
            dismissViewControllerAnimated(true, completion: nil)
            break
        case MessageComposeResultSent:
            print("Message sent")
            dismissViewControllerAnimated(true, completion: nil)
            createQuestion()
            break
        default:
            break
        }
    }
    
    func createQuestion() {
        let textPresent = answerOneContent.text != "" || answerTwoContent.text != ""
        let imagePresent = answerOneButton.currentBackgroundImage != UIImage(named: "placeholder") || answerTwoButton.currentBackgroundImage != UIImage(named: "placeholder")
        
        let textBothPresent = answerOneContent.text != "" && answerTwoContent.text != ""
        let imagesBothPresent = answerOneButton.currentBackgroundImage != UIImage(named: "placeholder") && answerTwoButton.currentBackgroundImage != UIImage(named: "placeholder")
        
        let bothImageText = textBothPresent && imagesBothPresent
        let justText = textBothPresent && !imagePresent
        let justImage = imagesBothPresent && !textPresent
        
        if questionContent.text != "" && (bothImageText || (!bothImageText && justText)) {
            let questionText = questionContent.text
            
            let currentDate = NSDate()
            let calender = NSCalendar.currentCalendar()
            let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
            
            let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
            
            question = Question(ID: "1234", content: questionText!, date: date, owner: model.user.uid)
            
            if bothImageText {
                let answerOneText = answerOneContent.text
                let answerTwoText = answerTwoContent.text
                
                let answerOneImage = answerOneButton.currentBackgroundImage
                let answerTwoImage = answerTwoButton.currentBackgroundImage
                
                let answerOne = Answer(id: "1234", text: answerOneText!, photo: answerOneImage!)
                let answerTwo = Answer(id: "1235", text: answerTwoText!, photo: answerTwoImage!)
                
                question.answers.append(answerOne)
                question.answers.append(answerTwo)
            }
            else if justText {
                let answerOneText = answerOneContent.text
                let answerTwoText = answerTwoContent.text
                
                let answerOne = Answer(id: "1234", text: answerOneText!)
                let answerTwo = Answer(id: "1235", text: answerTwoText!)
                
                question.answers.append(answerOne)
                question.answers.append(answerTwo)
            }
            
            LoadingOverlay.shared.showOverlay(self.view)
            self.view.endEditing(true)
            setUserInteraction(false)
                        
            dispatch_async(dispatch_get_main_queue()){
                // Group Question
                if self.group != nil {
                    self.createGroupQuestion()
                }
                    // Private Question
                else {
                    self.createPrivateQuestion()
                }
            }
        }
        else if questionContent.text == "" {
            ShowPopUpDailog("Oops", message: ("Must Enter Question Content"))
        }
        else if !textBothPresent {
            ShowPopUpDailog("Oops", message: ("Must Enter Both Question Answer Text"))
        }
    }
    
    func createPrivateQuestion() {
        let currentDate = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
        
        let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
        
        if contacts.count != 0 {
            for index in 0...contacts.count - 1 {
                let contact = contacts[index]
                if contact.uid != nil {
                    let uid = contacts[index].uid
                    recentKeys.append(uid)
                    print(uid)
                }
                else {
                    let number = contacts[index].number
                    recentKeys.append(number)
                    print(number)
                }
            }
        }
        
        recentKeys.append(model.user.uid)
        
        let currentUser = model.user
        let userContact = Contact(name: currentUser.username, number: currentUser.phoneNumber, uid: currentUser.uid)
        contacts.append(userContact)
        
        var manualText = manualEntryTextfield.text
        manualText = manualText?.trim()
        let manualTextSplit = manualText?.componentsSeparatedByString(",")
        
        if manualText != "" {
            var index = 0
            var accountContacts = contacts
            
            for entry in manualTextSplit! {
                print(entry)
                if entry != "" {
                    // Check if there is an account with that phone number
                    self.ref.child("Accounts").queryOrderedByChild("phone").queryStartingAtValue(entry).queryEndingAtValue(entry).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        // Account found
                        if snapshot.childrenCount != 0 {
                            for (key, value) in snapshot.value as! [String: [String : AnyObject]] {
                                self.recentKeys.append(key)
                                let account = Account(uid: key, snapshot: value)
                                let accountContact = Contact(name: account.username, number: account.phoneNumber, uid: account.uid)
                                accountContacts.append(accountContact)
                            }
                            
                            index = index + 1
                            
                            if index == manualTextSplit?.count {
                                for key in self.recentKeys {
                                    let response = Response(owner: key, answer: "TBA", date: date)
                                    self.question.responses.append(response)
                                    
                                    if key == self.model.user.uid {
                                        self.recentKeys.removeAtIndex(self.recentKeys.indexOf(key)!)
                                    }
                                }
                                
                                self.question.ID = self.firebaseModel.createPrivateQuestion(self.question.content, answers: self.question.answers, responses: self.question.responses, owner: self.question.owner)
                                self.firebaseModel.updateAccountContacts(self.question.ID, uid: self.model.user.uid, contacts: accountContacts, keys: self.recentKeys)
                                self.resetFields()

                                self.performSegueWithIdentifier("passQuestion", sender: self)
                            }
                        }
                            // Account not found
                        else {
                            // Check if there is an account with that email
                            self.ref.child("Accounts").queryOrderedByChild("email").queryStartingAtValue(entry).queryEndingAtValue(entry).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                // Account found
                                if snapshot.childrenCount != 0 {
                                    for (key, value) in snapshot.value as! [String: [String : AnyObject]] {
                                        self.recentKeys.append(key)
                                        let account = Account(uid: key, snapshot: value)
                                        let accountContact = Contact(name: account.username, number: account.phoneNumber, uid: account.uid)
                                        accountContacts.append(accountContact)
                                    }
                                }
                                    // Account not found
                                else {
                                    self.recentKeys.append(entry)
                                }
                                
                                index = index + 1
                                
                                if index == manualTextSplit?.count {
                                    for key in self.recentKeys {
                                        let response = Response(owner: key, answer: "TBA", date: date)
                                        self.question.responses.append(response)
                                        
                                        if key == self.model.user.uid {
                                            self.recentKeys.removeAtIndex(self.recentKeys.indexOf(key)!)
                                        }
                                    }
                                    
                                    self.question.ID = self.firebaseModel.createPrivateQuestion(self.question.content, answers: self.question.answers, responses: self.question.responses, owner: self.question.owner)
                                    self.firebaseModel.updateAccountContacts(self.question.ID, uid: self.model.user.uid, contacts: accountContacts, keys: self.recentKeys)
                                    self.resetFields()

                                    self.performSegueWithIdentifier("passQuestion", sender: self)
                                }
                            })
                        }
                    })
                }
                else {
                    index = index + 1
                    
                    if index == manualTextSplit?.count {
                        for key in self.recentKeys {
                            let response = Response(owner: key, answer: "TBA", date: date)
                            self.question.responses.append(response)
                            
                            if key == self.model.user.uid {
                                self.recentKeys.removeAtIndex(self.recentKeys.indexOf(key)!)
                            }
                        }
                        
                        self.question.ID = self.firebaseModel.createPrivateQuestion(self.question.content, answers: self.question.answers, responses: self.question.responses, owner: self.question.owner)
                        self.firebaseModel.updateAccountContacts(self.question.ID, uid: self.model.user.uid, contacts: accountContacts, keys: self.recentKeys)
                        self.resetFields()
                        
                        self.performSegueWithIdentifier("passQuestion", sender: self)
                    }
                }
            }
        }
        else {
            for key in recentKeys {
                let response = Response(owner: key, answer: "TBA", date: date)
                question.responses.append(response)
            }
            
            self.question.ID = self.firebaseModel.createPrivateQuestion(self.question.content, answers: self.question.answers, responses: self.question.responses, owner: self.question.owner)
            self.firebaseModel.updateAccountContacts(self.question.ID, uid: self.model.user.uid, contacts: self.contacts, keys: self.recentKeys)
            self.resetFields()

            self.performSegueWithIdentifier("passQuestion", sender: self)
        }
    }
    
    func createGroupQuestion() {
        self.question.ID = self.firebaseModel.createGroupContactsQuestion(self.question.content, answers: self.question.answers, responses: self.question.responses, owner: self.question.owner, group: self.group)
        self.firebaseModel.updateAccountContacts(self.question.ID, uid: self.model.user.uid, contacts: self.contacts, keys: self.recentKeys)
        self.resetFields()

        self.performSegueWithIdentifier("passQuestion", sender: self)
    }
    
    @IBAction func selectAnswerOneImage(sender: AnyObject) {
        answerOneImagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: nil,message: nil,preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibAction = UIAlertAction(title: "Photo Library", style: .Default) { (action: UIAlertAction) -> Void in
            self.answerOneImagePicker.sourceType = .PhotoLibrary

            self.presentViewController(self.answerOneImagePicker, animated: true, completion: nil)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { (action: UIAlertAction) -> Void in
            self.answerOneImagePicker.sourceType = .Camera
            
            self.presentViewController(self.answerOneImagePicker, animated: true, completion: nil)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: .Default) { (action: UIAlertAction) -> Void in
            self.answerOneButton.setBackgroundImage(UIImage(named: "placeholder"), forState: .Normal)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(photoLibAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(removePhotoAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func selectAnswerTwoImage(sender: AnyObject) {
        answerTwoImagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: nil,message: nil,preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibAction = UIAlertAction(title: "Photo Library", style: .Default) { (action: UIAlertAction) -> Void in
            self.answerTwoImagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.answerTwoImagePicker, animated: true, completion: nil)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { (action: UIAlertAction) -> Void in
            self.answerTwoImagePicker.sourceType = .Camera
            
            self.presentViewController(self.answerTwoImagePicker, animated: true, completion: nil)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let removePhotoAction = UIAlertAction(title: "Remove Photo", style: .Default) { (action: UIAlertAction) -> Void in
            self.answerTwoButton.setBackgroundImage(UIImage(named: "placeholder"), forState: .Normal)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(photoLibAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(removePhotoAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Create Group" {
            if contacts.count != 0 {
                let createGroupVC = segue.destinationViewController as! CreateGroupViewController
                createGroupVC.selectedContacts = selectedPCContacts
            }
        }
        else if segue.identifier == "passQuestion" {
            let resultsController = segue.destinationViewController as! GroupQuestionResultViewController
            question.responses.removeAll()
            resultsController.question = question
        }
        else if segue.identifier == "PhoneContact" {
            let selectPCController = segue.destinationViewController as! AddPhoneContactViewController
            selectPCController.selectedNumbers = selectedPCNumbers
        }
        else if segue.identifier == "FBContact" {
            let selectSMController = segue.destinationViewController as! SelectFBContactsViewController
            selectSMController.selectedUids = selectedFBUids
        }
    }
    
    @IBAction func unwindToQuestionCreation (segue : UIStoryboardSegue) {
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if picker == answerOneImagePicker {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                answerOneButton.setBackgroundImage(pickedImage, forState: .Normal)
            }
        }
        else {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                answerTwoButton.setBackgroundImage(pickedImage, forState: .Normal)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 83/255, green: 216/255, blue: 212/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        header.alpha = 0.5 //make the header transparent
    }
    
    func ShowPopUpDailog(title:String, message:String){
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "ok", style: .Default) { (Action) in
            // self.dismissViewControllerAnimated(true, completion: nil)
            print("ok clicked")
        }
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func setUserInteraction(b:Bool){
        questionContent.userInteractionEnabled = b
        answerOneContent.userInteractionEnabled = b
        answerTwoContent.userInteractionEnabled = b
        answerOneButton.userInteractionEnabled = b
        answerTwoButton.userInteractionEnabled = b
        manualEntryTextfield.userInteractionEnabled = b
        self.tableView.allowsSelection = b
    }
    
    func resetFields() {
        questionContent.text = ""
        answerOneContent.text = ""
        answerOneButton.setBackgroundImage(UIImage(named: "placeholder"), forState: .Normal)
        answerTwoContent.text = ""
        answerTwoButton.setBackgroundImage(UIImage(named: "placeholder"), forState: .Normal)
        manualEntryTextfield.text = ""
        
        contacts.removeAll()
        recentKeys.removeAll()
        selectedPCNumbers.removeAll()
        selectedFBUids.removeAll()
        selectedPCContacts.removeAll()
        selectedSMContacts.removeAll()
        group = nil
        
        pcInvitedCount.text = "0 Invited"
        smInviteCount.text = "0 Invited"
        sendToGroupLabel.text = ""
    }
}

extension String {
    func trim() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
}