//
//  ProfileViewController.swift
//  pPoll
//
//  Created by Nath on 9/7/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class ProfileTableViewController:UITableViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate{
    @IBOutlet weak var emailTF: UILabel!
    
    
    @IBOutlet weak var photoCellView: UIView!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var photoImage: UIImageView!
    var screenObject=UIScreen.mainScreen().bounds;
    
    @IBOutlet weak var gender: UISegmentedControl!
    
    @IBOutlet weak var nationalityTF: UITextField!
    
    @IBOutlet weak var interestedBtn: UIButton!
    @IBOutlet weak var photoBgImageView: UIImageView!
    @IBOutlet weak var citizenshipTF: UITextField!
    let fireBaseModel = ModelFirebase.sharedInstance
    let model = Model.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        model.isSignUpDetailPage = false;
        initPhotoImage()
        nationalityTF.delegate = self
        citizenshipTF.delegate = self
        dobTF.delegate = self
        
        addClickAction()
        
        loadInfo()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func loadInfo(){
        //        let user = model.user
        emailTF.text = model.user.emailAddress
        if let user = model.user.profile {
            if user.gender=="male" {
                gender.selectedSegmentIndex = 0
            }else{
                gender.selectedSegmentIndex = 1
            }
            citizenshipTF.text = user.citizenship
            nationalityTF.text = user.nationality
            dobTF.text = user.dateOfBirth
            photoImage.image = user.photo
        }
        let topicTitle = "Interested Topic ( " + String(model.interestedTopics.count) + " )";
        
        interestedBtn.setTitle(topicTitle, forState: UIControlState.Normal)
        
    }
    
    
    @IBAction func backBtnClickAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func saveBtnClickAction(sender: AnyObject) {
        
        saveProfile()
    }
    func saveProfile(){
        if FIRAuth.auth()?.currentUser?.uid != nil{
            let currentDate = NSDate()
            let calender = NSCalendar.currentCalendar()
            let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
            
            let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
            
            let genderValue = gender.titleForSegmentAtIndex(gender.selectedSegmentIndex)
            let dob = dobTF.text
            let nationality = nationalityTF.text
            let citizenship = citizenshipTF.text
            
            let profileArray = ["gender":genderValue!,"dateOfBirth":dob!,"citizenship":citizenship!,"nationality":nationality!, "dateCreated": date];
            fireBaseModel.updateProfile(model.user.uid,profileArray: profileArray)
            fireBaseModel.uploadProfileImage(model.user.uid, image: photoImage.image!)
            model.addUserProfileImage(photoImage.image!)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController3") as! StartUpViewController
        model.interestedTopics.removeAll()
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.window?.rootViewController = viewController
    }
    
    func initPhotoImage(){
        let imageSize:CGFloat = 75.0 * 2
        photoImage.layer.cornerRadius = photoImage.bounds.size.width;
        photoImage.clipsToBounds = true
        photoImage.bounds = CGRectMake((self.view.bounds.size.width-imageSize)/2, (self.view.bounds.size.height-imageSize)/2-150, imageSize, imageSize)
        photoImage.frame = CGRectMake((self.view.bounds.size.width-imageSize)/2, (self.view.bounds.size.height-imageSize)/2-150, imageSize, imageSize)
        
        photoImage.layer.cornerRadius = CGRectGetHeight(photoImage.bounds)/2
        
        
        photoImage.layer.masksToBounds = true
        photoImage.layer.borderColor = UIColor.whiteColor().CGColor
        photoImage.layer.borderWidth = 3
        
        //set bg
        let background = turquoiseColor()
        //        background.frame = photoViewBg.bounds
        background.frame = self.photoCellView.bounds
        let blurEffect = UIBlurEffect(style:UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        //        blurView.frame.size = CGSize(width: photoCellView.frame.width, height: photoCellView.frame.height)
        blurView.frame = photoCellView.frame
        //      photoViewBg.layer.insertSublayer(background, atIndex: 0)
        photoBgImageView.addSubview(blurView)
        
        
    }
    
    //颜色渐变
    
    func turquoiseColor() -> CAGradientLayer {
        let topColor = UIColor(colorLiteralRed: 0/255.0, green: 255/255.0, blue: 204/255.0, alpha: 1.0)
        
        let bottomColor = UIColor(colorLiteralRed: 86/255.0, green: 186/255.0, blue: 42/255.0, alpha: 1.0)
        
        let gradientColors: Array <AnyObject> = [topColor.CGColor, bottomColor.CGColor]
        
        let gradientLocations: Array <NSNumber> = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.colors = gradientColors
        
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    
    func addClickAction(){
        
        //1. add photo image action
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        photoImage.userInteractionEnabled = true
        photoImage.addGestureRecognizer(tapGestureRecognizer)
        //2. add age text field acton
        
        dobTF.addTarget(self, action: #selector(self.myTargetFunction(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:Selector("textFieldTapped:"))
        dobTF.userInteractionEnabled = true
        dobTF.addGestureRecognizer(tapGestureRecognizer2)
        //3. add tap action for hiding keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard:"))
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
    
    
    //memory warning
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning();
        print("个人信息内存警告");
    }
    
    
    @IBAction func onAgeTFClicked(sender: AnyObject) {
        print("age textfield tapped")
    }
    
    
    func myTargetFunction(textField: UITextField) {
        // user touch field
        print("age textfield tapped")
    }
    
    /**
     methods for
     UIImagePickerControllerDelegate and UINavigationControllerDelegate
     **/
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        photoImage.image = image
    }
    
}


