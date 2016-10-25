//
//  SignUpDetailController.swift
//  pPoll
//
//  Created by WangXin on 16/10/3.
//  Copyright © 2016年 syle. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class SignUpDetailController: UIViewController, UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate ,UIPickerViewDataSource,UIPickerViewDelegate{
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var citizenshipTextField: UITextField!
    @IBOutlet weak var topcSelectionBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var dobTextField: UITextField!
    let fireBaseModel = ModelFirebase.sharedInstance
    let model = Model.sharedInstance
    var isNationalityTextFieldEditing = false;
    var ref: FIRDatabaseReference!
    let dobPicker = UIDatePicker();
    override func viewDidLoad() {
        super.viewDidLoad()
        model.isSignUpDetailPage = true;
        ref = FIRDatabase.database().reference()
        initUI()
    }
    @IBAction func goToTopicSelectionPage(sender: AnyObject) {
    }
    func initUI(){
        self.view.addBackground()
        initPhotoImage()
        addClickAction()
        subView.layer.cornerRadius = 10
        topcSelectionBtn.layer.cornerRadius = 5
        skipBtn.layer.cornerRadius = 5
        saveBtn.layer.cornerRadius = 5
        let countryPicker = UIPickerView();
        countryPicker.backgroundColor = UIColor.whiteColor()
        countryPicker.delegate = self;
        countryPicker.dataSource = self;
        nationalityTextField.delegate = self;
        nationalityTextField.inputView = countryPicker;
        citizenshipTextField.inputView = countryPicker;
        dobPicker.backgroundColor = UIColor.whiteColor()
        dobPicker.datePickerMode = UIDatePickerMode.Date
        //        dobPicker.minimumDate =
        dobPicker.addTarget(self, action: "dateChanged",
                            forControlEvents: UIControlEvents.ValueChanged)
        dobTextField.inputView = dobPicker
        
        let topicTitle = "Interested Topic ( " + String(model.interestedTopics.count) + " )";
        
        topcSelectionBtn.setTitle(topicTitle, forState: UIControlState.Normal)
        
    }
    
    func initPhotoImage(){
        let imageSize:CGFloat = 50.0 * 2
        photoImage.layer.cornerRadius = photoImage.bounds.size.width;
        photoImage.clipsToBounds = true
        photoImage.bounds = CGRectMake((self.view.bounds.size.width-imageSize)/2, (self.view.bounds.size.height-imageSize)/2-imageSize, imageSize, imageSize)
        photoImage.frame = CGRectMake((self.view.bounds.size.width-imageSize)/2, (self.view.bounds.size.height-imageSize)/2-imageSize, imageSize, imageSize)
        // 用设置圆角的方法设置圆形
        photoImage.layer.cornerRadius = CGRectGetHeight(photoImage.bounds)/2
        
        // 设置图片的外围圆框*
        photoImage.layer.masksToBounds = true
        photoImage.layer.borderColor = UIColor.whiteColor().CGColor
        photoImage.layer.borderWidth = 3
        
    }
    
    
    @IBAction func inviteFriendsBtClicked(sender: AnyObject) {
        ShowShareSheet()
    }
    
    func ShowShareSheet (){
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        let inviteAction = UIAlertAction(title: "Invite from FaceBook", style: .Default) { (Action) in
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: "https://www.mydomain.com/myapplink")!
            //optionally set previewImageURL
            content.appInvitePreviewImageURL = NSURL(string: "https://www.mydomain.com/my_invite_image.jpg")!
            // Present the dialog. Assumes self is a view controller
            // which implements the protocol `FBSDKAppInviteDialogDelegate`.
            FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
            
        }
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        
        myAlert.addAction(cancelActionButton)
        myAlert.addAction(inviteAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func addClickAction(){
        
        //1. add photo image action
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        photoImage.userInteractionEnabled = true
        photoImage.addGestureRecognizer(tapGestureRecognizer)
        //2. add tap action for hiding keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard:"))
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        photoImage.image = image
    }
    
    func imageTapped(img: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.editing = false;
        imagePicker.delegate = self;
        let alertController = UIAlertController(title: nil,message: nil,preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibAction = UIAlertAction(title: "Photo Library", style: .Default) { (action: UIAlertAction) -> Void in
            
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion:
                nil
            )
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) { (action: UIAlertAction) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion:
                nil
            )
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(photoLibAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func hideKeyboard(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            print("hide keyboard")
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func dateChanged(){
        dobTextField.text = NSDateFormatter.localizedStringFromDate(dobPicker.date, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        
        NSLog("textFieldDidBeginEditing")
        isNationalityTextFieldEditing = true;
    }
    var data = ["Australia","America","England","China","Japan","India"]
    // methods for UIPickerViewDataSource,Delegate
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return data.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(isNationalityTextFieldEditing){
            nationalityTextField.text = data[row]
        }else{
            citizenshipTextField.text = data[row]
        }
        isNationalityTextFieldEditing = false;
        
    }
    
    @IBAction func skipBtnClicked(sender: AnyObject) {
        
        saveEmptyProfile()
        GoToHomePage();
    }
    @IBAction func saveBtnClicked(sender: AnyObject) {
        saveProfile();
        GoToHomePage();
    }
    func saveProfile(){
        if FIRAuth.auth()?.currentUser?.uid != nil{
            let currentDate = NSDate()
            let calender = NSCalendar.currentCalendar()
            let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
            
            let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
            
            let genderValue = genderSegment.titleForSegmentAtIndex(genderSegment.selectedSegmentIndex)
            let dob = dobTextField.text
            let nationality = nationalityTextField.text
            let citizenship = citizenshipTextField.text
            
            let profileArray = ["gender":genderValue!,"dateOfBirth":dob!,"citizenship":citizenship!,"nationality":nationality!, "dateCreated": date];
            LoadingOverlay.shared.showOverlay(view)
            fireBaseModel.updateProfile(model.user.uid,profileArray: profileArray)
            fireBaseModel.uploadProfileImage(model.user.uid, image: photoImage.image!)
            LoadingOverlay.shared.hideOverlayView()
        }
        
    }
    
    func saveEmptyProfile(){
        if FIRAuth.auth()?.currentUser?.uid != nil{
            let currentDate = NSDate()
            let calender = NSCalendar.currentCalendar()
            let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
            
            let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
            
            let profileArray = ["gender":"","dateOfBirth":"","citizenship":"","nationality":"", "dateCreated": date];
            LoadingOverlay.shared.showOverlay(view)
            fireBaseModel.updateProfile(model.user.uid,profileArray: profileArray)
            fireBaseModel.uploadProfileImage(model.user.uid, image: UIImage(named: "p logo")!)
            LoadingOverlay.shared.hideOverlayView()
        }
        
    }
    
    func GoToHomePage(){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        //fireBaseModel.loadTopic()
        
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
                    
                    self.fireBaseModel.getProfileImage(account.uid, image: { (image) in
                        self.model.addProfileImage(profile, image: image!)
                    })
                }
            })
            
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("showHomePage", sender: self)
            }
        })
    }
    
    
}

extension SignUpDetailController: FBSDKAppInviteDialogDelegate {
    //MARK: FBSDKAppInviteDialogDelegate
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invitation made")
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("error made")
    }
}
