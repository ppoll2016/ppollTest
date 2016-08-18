//
//  LoginController.swift
//  pPoll
//
//  Created by 薛晨 on 15/08/2016.
//  Copyright © 2016 syle. All rights reserved.
//


import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class LoginController: UIViewController {
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var forgetButton: UIButton!
    @IBOutlet weak var Facebook: UIButton!
    @IBOutlet weak var Twitter: UIButton!
    @IBOutlet weak var Linkedin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius  = 10
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Facebook(sender: AnyObject) {
        let login: FBSDKLoginManager = FBSDKLoginManager()
        
        login.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) in
            if error != nil {
                print(error.localizedDescription)
            }else if result.isCancelled{
                print("cancelled")
            }else{
                print("logged in")
            }
        }
        
    }
    @IBAction func linkedInBtnClicked(sender: AnyObject) {
        
        
    }
    
    
    
}
