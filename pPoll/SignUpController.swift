//
//  SignUpController.swift
//  pPoll
//
//  Created by 薛晨 on 15/08/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UITextFieldDelegate {
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var UserNameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPwTextField: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBOutlet weak var phoneNumTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        RegisterButton.layer.cornerRadius = 10
        RegisterButton.userInteractionEnabled = false
        RegisterButton.backgroundColor = UIColor.grayColor()
        
        subView.layer.cornerRadius = 10
        subView.backgroundColor = UIColor(netHex: 0x00CCCC)
        self.view.addBackground()
        
        UserNameTextField.delegate = self
        EmailTextField.delegate = self
        phoneNumTextField.delegate = self
        PasswordTextField.delegate = self
        ConfirmPwTextField.delegate = self
        
        EmailTextField.keyboardType = UIKeyboardType.EmailAddress
        phoneNumTextField.keyboardType = UIKeyboardType.PhonePad
        
        UserNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        EmailTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        phoneNumTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        PasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        ConfirmPwTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: Method to move the view when keyboard appear
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -100
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    //MARK: TextField Delegate Method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Handle enable button
    func textFieldDidChange(textField: UITextField) {
        if(EmailTextField.text != "" && PasswordTextField.text != "" &&
            ConfirmPwTextField.text != "" && PasswordTextField.text != "")
        {
            RegisterButton.userInteractionEnabled = true
            RegisterButton.backgroundColor = UIColor(netHex: 0x0099CC)
            print("ok ")
        }else{
            RegisterButton.userInteractionEnabled = false
            RegisterButton.backgroundColor = UIColor.grayColor()
            print("No way")
        }
    }
    
    @IBAction func BackBtClicked(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Register button clicked
    @IBAction func RegisterBtClicked(sender: AnyObject) {
        if(PasswordTextField.text == ConfirmPwTextField.text){
            if(checkTextSufficientComplexity(PasswordTextField.text!)){
                print("Pass")
                
            }else{
                ShowPopUpDailog("Password Need At Least 6 Characters and include number, Uppercase and Lowercase letter", message: "Try again")
                return
            }
            
        }else{
            ShowPopUpDailog("Password not match", message: "Try again")
            return
        }
        
        guard let username = UserNameTextField.text, email = EmailTextField.text, password = PasswordTextField.text else{
            print("wrong format")
            return
        }
        let phoneNumber = phoneNumTextField.text!
        LoadingOverlay.shared.showOverlay(self.view)
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: {
            (user:FIRUser?, error) in
            LoadingOverlay.shared.hideOverlayView()
            if error != nil {
                self.ShowPopUpDailog("Register failed", message: (error?.localizedDescription)!)
                print(error)
                return
            }
            // grab the unique id
            guard let uid = user?.uid else {
                return
            }
            // grab an instance of firebase realtime database
            let ref = FIRDatabase.database().referenceFromURL("https://ppoll-1d745.firebaseio.com/")
            let accountNode = ref.child("Accounts").child(uid)
            
            let values = ["email": email,"phoneNumber":phoneNumber, "username": username, "isPremium": false]
            
            accountNode.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, FIRDatabaseReference) in
                if err != nil{
                    print(err)
                }
            })
            
            let account = Account(uid: uid, username: username, emailAddress: email,phoneNumber: phoneNumber, isPremium: false)
            //self.model.user = account
            self.model.addUserAccount(account)
            self.firebaseModel.updateUIDForRecentPage(uid,phoneNum: phoneNumber,email: email);
            print("User Created and saved to database")
            //            self.GoToHomePage()
            self.firebaseModel.loadTopic()
            self.goToSignUpDetailPage()
            
        })
        
        
    }
    
    func checkTextSufficientComplexity( text : String) -> Bool{
        
        var textSize = false
        let size = text.characters.count
        if (size >= 6 && size <= 16){
            textSize = true
        }
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluateWithObject(text)
        print("\(capitalresult)")
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluateWithObject(text)
        print("\(numberresult)")
        
        let lowerCaseCharacterRegEx  = ".*[a-z]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", lowerCaseCharacterRegEx)
        let lowerCaseresult = texttest2.evaluateWithObject(text)
        print("\(lowerCaseresult)")
        
        //        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        //        var texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        //        var specialresult = texttest2.evaluateWithObject(text)
        //        print("\(specialresult)")
        
        return textSize && capitalresult && numberresult && lowerCaseresult
        
    }
    
    func ShowPopUpDailog( title:String, message:String){
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "ok", style: .Default) { (Action) in
            // self.dismissViewControllerAnimated(true, completion: nil)
            print("ok clicked")
        }
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    func goToSignUpDetailPage(){
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("goToSignUpDetailPage", sender: self)
        }
        
    }
    func GoToHomePage(){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("Topics").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            print("Adding topic " + snapshot.key + " to model")
            let topic = Topic(name: snapshot.key)
            self.model.addTopic(topic)
            
            // Get the image from storage DB
            self.firebaseModel.getTopicImage(snapshot.key, image: { (image) in
                if image != nil {
                    self.model.addTopicImage(topic, image: image!)
                }
            })
        })
        
        // Get user account
        ref.child("Accounts").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let
            accountSnapshot = snapshot.value as! [String: AnyObject]
            print("User account retrieved")
            let account = Account(uid: uid!, snapshot: accountSnapshot)
            self.model.addUserAccount(account)
            
            // Add profile
            self.ref.child("Profiles").child(snapshot.key).observeEventType(.Value, withBlock: { (snapshot) in let profileSnapshot = snapshot.value as? [String: AnyObject]
                if profileSnapshot != nil {
                    let profile = Profile(snapshot: profileSnapshot!)
                    self.model.addProfile(account, profile: profile)
                    
                    self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                        self.model.addProfileImage(profile, image: image!)
                    })
                }
            })
            
            // Adding contact
            self.ref.child("AccountContacts").child(snapshot.key).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                print("Adding a contact " + snapshot.key + " to user")
                self.ref.child("Accounts").child(snapshot.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let
                    accountSnapshot = snapshot.value as! [String: AnyObject]
                    let account = Account(uid: snapshot.key, snapshot: accountSnapshot)
                    self.model.addAccount(account)
                    self.model.addContact(account)
                    
                })
            })
            
            // Removing contact
            self.ref.child("AccountContacts").child(snapshot.key).observeEventType(.ChildRemoved, withBlock: { (snapshot) in
                print("Removing a contact " + snapshot.key + " from user")
                self.model.removeContact(snapshot.key)
            })
            
            
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("goToSignUpDetailPage", sender: self)
            }
        })
    }
    
    
}
