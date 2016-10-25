//
//  LoginController.swift
//  pPoll
//
//  Created by 薛晨 on 15/08/2016.
//  Copyright © 2016 syle. All rights reserved.
//


import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class LoginController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    var ref: FIRDatabaseReference!
    var fbUserName: String!
    var fbUserEmail: String!
    var fbUserGender: String!
    var userProfileImage: UIImage!
    var fbID: String!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var FBLoginBt: FBSDKLoginButton!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var distancepPolllogoToTopLayout: NSLayoutConstraint!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var forgetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        loginButton.layer.cornerRadius  = 10
        FBLoginBt.layer.cornerRadius = 10
        loginButton.userInteractionEnabled = false
        loginButton.backgroundColor = UIColor.grayColor()
        FBLoginBt.delegate = self
        FBLoginBt.readPermissions = ["public_profile","email","user_friends"]
        
        FBLoginBt.userInteractionEnabled = true
        
        subView.layer.cornerRadius = 10
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
        EmailTextField.keyboardType = UIKeyboardType.EmailAddress
        
        EmailTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        PasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        
        subView.backgroundColor = UIColor(netHex: 0x00CCCC)
        distancepPolllogoToTopLayout.constant = distancepPollLogoToTopLayoutConstraintConstant()
        self.view.addBackground()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userProfileImage = UIImage(named: "placehodler")
    }
    
    
    //MARK: Method to move the view when keyboard appear
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -50
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func screenHeight() -> CGFloat {
        return UIScreen.mainScreen().bounds.height;
    }
    
    func distancepPollLogoToTopLayoutConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
            
        case 667://iphone 6
            return 45
            
        case 736://iphone 6p
            return 55
            
        default://iphone 4
            return 20
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Handle enable button
    func textFieldDidChange(textField: UITextField) {
        if(EmailTextField.text != "" && PasswordTextField.text != "")
        {
            loginButton.userInteractionEnabled = true
            loginButton.backgroundColor = UIColor(netHex: 0x0099CC)
        }else{
            loginButton.userInteractionEnabled = false
            loginButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    @IBAction func BackBtClicked(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Login with email and forget password
    @IBAction func LoginWithEmail(sender: AnyObject) {
//        SwiftSpinner.show("Loading...").addTapHandler({}, subtitle: "By the pPoll, For the pPoll")
        LoadingOverlay.shared.showOverlay(self.view)
        self.view.endEditing(true)
        setUserInteraction(false)
        LoginWithEmailInGCD()
    }
    
    func LoginWithEmailInGCD() {

        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue){

            let group = dispatch_group_create()
            dispatch_group_async(group, queue) {
                FIRAuth.auth()?.signInWithEmail(self.EmailTextField.text!.removeWhitespace(), password: self.PasswordTextField.text!, completion: {
                    (user, error) in
                    if error != nil{
                        dispatch_async(dispatch_get_main_queue()) {
                            LoadingOverlay.shared.hideOverlayView()
                            print("password or email is incorrect")
                            self.ShowPopUpDailog("Oops", message: (error?.localizedDescription)!)
                            self.setUserInteraction(true)
                        }
                        
                    }else{
                        print("User pass from login")
                        self.GoToHomePage1()
                    }
                })
            }
            
        }
    }
    
    @IBAction func ForgetPassWordBtClicked(sender: AnyObject) {
        if self.EmailTextField.text == "" {
            ShowPopUpDailog("Oops", message: "Please enter an email")
        }else{
            FIRAuth.auth()?.sendPasswordResetWithEmail(self.EmailTextField.text!, completion: { (error) in
                if error != nil {
                    print(error?.localizedDescription)
                    self.ShowPopUpDailog("Oops", message: (error?.localizedDescription)!)
                }
                self.ShowPopUpDailog("Succeed", message: "Reset password email has send to \(self.EmailTextField.text!)")
            })
        }
    }
    
    //MARK: FaceBook login
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        LoadingOverlay.shared.showOverlay(self.view)
        setUserInteraction(false)
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            print(error.localizedDescription)
            LoadingOverlay.shared.hideOverlayView()
            self.ShowPopUpDailog("Oops", message: error.localizedDescription)
            self.setUserInteraction(true)
        }else{
            print("logged in through FB")
            FBLoginBt.userInteractionEnabled = false
            
            if let _ = FBSDKAccessToken.currentAccessToken() {
                self.fetchFBUserProfile()
                self.linkToFireBaseInGCD()

            }else{
                LoadingOverlay.shared.hideOverlayView()
                self.setUserInteraction(true)
            }
            
        }
    }
    
    func linkToFireBaseInGCD() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue){
            let group = dispatch_group_create()
            dispatch_group_async(group, queue) {
               // self.fetchFBUserProfile()
                let credentail = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                self.LinkToFirebase(credentail)
            }
            dispatch_group_notify(group, queue){
                dispatch_async(dispatch_get_main_queue()){
                    
                }
            }
        }
    }
    
    func fetchFBUserProfile() {
        let parameters = ["fields": "id, gender, name, email, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            print("fetch user detail")
            if requestError != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    LoadingOverlay.shared.hideOverlayView()
                    self.ShowPopUpDailog("Error", message: (requestError?.localizedDescription)!)
                    self.setUserInteraction(true)
                }
                print(requestError.localizedDescription)
                return
            }
            print(user)
            self.fbID = user["id"] as? String ?? "fb\(arc4random_uniform(1000000))"
            self.fbUserGender = user["gender"] as? String ?? ""
            self.fbUserEmail = user["email"] as? String ?? ""
            self.fbUserName = user["name"] as? String ?? "user\(arc4random_uniform(1000000))"
            
            print("Finish Grab Fbuser email and name")
            var pictureUrl = ""
            
            if let picture = user["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                pictureUrl = url
            }
            
            let url = NSURL(string: pictureUrl)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        LoadingOverlay.shared.hideOverlayView()
                        self.ShowPopUpDailog("Error", message: (error?.localizedDescription)!)
                        self.setUserInteraction(true)
                    }
                    print(error)
                    return
                }
                let image = UIImage(data: data!)
                self.userProfileImage = image
                print(self.userProfileImage)
                print("finsih grabing facebook user profile image")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                })
                
            }).resume()
            
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("log put")
    }
    
    func checkForExistingAccessToken()->Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") != nil
    }
    
    //MARK: Link to firebase
    func LinkToFirebase(credentail: FIRAuthCredential){
        
        FIRAuth.auth()?.signInWithCredential(credentail, completion: {
            (user, error) in
            if error != nil{
                dispatch_async(dispatch_get_main_queue()) {
                    LoadingOverlay.shared.hideOverlayView()
                    self.ShowPopUpDailog("Error", message: (error?.localizedDescription)!)
                    self.setUserInteraction(true)
                }
                print(error)
                return
            }
            // grab the unique id
            guard let uid = user?.uid else {
                return
            }
            print("current uid " + uid)
            
            // Get the topics
            self.firebaseModel.loadTopic()
            
            self.ref.child("Accounts").child(uid).observeSingleEventOfType(.Value, withBlock: {
                (snap) in
                if let accountSnapshot = snap.value as? [String: AnyObject] {
                    print("FackBook account found ")
                    // facebook account exsit and put in the model
                    let account = Account(uid: uid, snapshot: accountSnapshot)
                    self.model.addUserAccount(account)
                    
                    // Add profile
                    self.ref.child("Profiles").child(snap.key).observeEventType(.Value, withBlock: { (snapshot) in
                        
                        if let profileSnapshot = snapshot.value as? [String: AnyObject] {
                            let profile = Profile(snapshot: profileSnapshot)
                            self.model.addUserProfile(account, profile: profile)
                            
                            self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                                self.model.addUserProfileImage(image!)
                                self.model.addProfileImageCore(account.uid, image: image!)
                            })
                        }
                    })
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        LoadingOverlay.shared.hideOverlayView()
                        self.performSegueWithIdentifier("showHomePage", sender: self)
                    }
                    
                }else{
                    print("FaceBook account not found in ")
                    self.uploadNewFaceBookAccountToFirebase(uid)
                }
                
            })
            
        })
    }
    
    
    func uploadNewFaceBookAccountToFirebase(uid: String){
        let currentDate = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
        
        let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
        // save account and profile to the model
        let fbAccount = Account(uid: uid, username: self.fbUserName, emailAddress: self.fbUserEmail, phoneNumber: "", isPremium: false)
        let fbProfile = Profile(dateOfBirth: "", gender: self.fbUserGender, citizenship: "", nationality: "", dateCreated: date)
        self.model.addUserAccount(fbAccount)
        self.model.addUserProfile(fbAccount, profile: fbProfile)
        self.model.addUserProfileImage(self.userProfileImage)
        self.model.addProfileImageCore(uid, image: self.userProfileImage)
        
        // update to firebase
        let values = ["email": self.fbUserEmail, "isPremium": false, "username": self.fbUserName, "FaceBookID": self.fbID ]
        
        let gender: String = self.fbUserGender
        let profileArray = ["gender":gender ,"dateOfBirth":"","citizenship":"","nationality":"", "dateCreated": date];
        self.firebaseModel.updateFaceBookProfile(uid,profileArray: profileArray)
        self.firebaseModel.uploadProfileImage(uid, image: self.userProfileImage)
        print("finsih update image to firebase")
        
        let accountNode = self.ref.child("Accounts").child(uid)
        accountNode.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, FIRDatabaseReference) in
            if err != nil{
                dispatch_async(dispatch_get_main_queue()) {
                    LoadingOverlay.shared.hideOverlayView()
                    self.ShowPopUpDailog("Error", message: (err?.localizedDescription)!)
                    self.setUserInteraction(true)
                }
                print(err)
            }
            print("Finish update FB user to firebase database")
            dispatch_async(dispatch_get_main_queue()) {
                LoadingOverlay.shared.hideOverlayView()
                self.performSegueWithIdentifier("showHomePage", sender: self)
            }
        })
    }
    
    
    func GoToHomePage1(){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        // Get the topics
        firebaseModel.loadTopic()
        
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
            
            dispatch_async(dispatch_get_main_queue()) {
                LoadingOverlay.shared.hideOverlayView()
                self.performSegueWithIdentifier("showHomePage", sender: self)
            }
        })
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
        EmailTextField.userInteractionEnabled = b
        PasswordTextField.userInteractionEnabled = b
        loginButton.userInteractionEnabled = b
        FBLoginBt.userInteractionEnabled = b
        forgetButton.userInteractionEnabled = b
        backButton.userInteractionEnabled = b
    }
    
    
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}


