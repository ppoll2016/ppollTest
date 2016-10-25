//
//  ViewController.swift
//  pPoll
//
//  Created by syle on 11/08/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class StartUpViewController: UIViewController {
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    var ref: FIRDatabaseReference!
  //  let loginManager = FBSDKLoginManager()

    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var distanceImageViewTopLayout: NSLayoutConstraint!
    @IBOutlet weak var loginWidth: NSLayoutConstraint!
    @IBOutlet weak var registerWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   LoadingOverlay.shared.showOverlay(self.view)
        ref = FIRDatabase.database().reference()
        

        loginButton.layer.cornerRadius  = 10
        registerButton.layer.cornerRadius = 10
        
        loginWidth.constant = buttonHeightConstraintConstant()
        registerWidth.constant = buttonHeightConstraintConstant()
        self.view.addBackground()
    
        imageViewWidth.constant = imageViewConstraintConstant()
        imageViewHeight.constant = imageViewConstraintConstant()
        distanceImageViewTopLayout.constant = distanceConstraintConstant()
        loginButton.backgroundColor = UIColor(netHex: 0x00CCCC)
        registerButton.backgroundColor = UIColor.grayColor()
        
        //delete all the data from last user if exist
        model.deleteCurrentUserQuestionsCore()
        model.questions.removeAll()
        
        if let _ = FBSDKAccessToken.currentAccessToken() {
            print("Has Facebook login")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
    }
    
    func screenHeight() -> CGFloat {
        return UIScreen.mainScreen().bounds.height;
    }
    
    func distanceConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
        case 568://iphone 5
            return 40
            
        case 667://iphone 6
            return 50
            
        case 736://iphone 6p
            return 60
            
        default://iphone 4
            return 40
        }
    }
    
    
    func imageViewConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
        case 568://iphone 5
            return 200
            
        case 667://iphone 6
            return 210
            
        case 736://iphone 6p
            return 225
            
        default://iphone 4
            return 260
        }
    }
    
    func buttonHeightConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
        case 568://iphone 5
            return 140
            
        case 667://iphone 6
            return 165
            
        case 736://iphone 6p
            return 180
            
        default://iphone 4
            return 140
        }
    }
    
    override func viewWillAppear(animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

