//
//  LoadingScreenViewController.swift
//  pPoll
//
//  Created by Nath on 9/7/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase

protocol LoadingViewDelegate {
    func fetchCurrentUserImageComplete()
}

class LoadingScreenViewController: UIViewController {
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    var ref: FIRDatabaseReference!
    var delegate:LoadingViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
//        try! FIRAuth.auth()!.signOut()
        
        ref = FIRDatabase.database().reference()
        self.view.backgroundColor = UIColor(red: 85/255.0, green: 183/255.0, blue: 186/255.0, alpha: 1.0)
        if FIRAuth.auth()?.currentUser?.uid != nil {
            loadUserData()
        }
        else {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController3") as! StartUpViewController
            
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.window?.rootViewController = viewController
        }
    }
    
    func loadUserData() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        //fetchTopics()
        // Add interested topic
        self.ref.child("InterestedTopic").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let profileSnapshot = snapshot.value as? [String: AnyObject]
            if profileSnapshot != nil {
                self.model.interestedTopics.removeAll()
                for topicName in (profileSnapshot?.keys)!{
                    self.model.addInterestedTopic(topicName)
                }
                
            }
        })
        // new topic image fetch method cooperate with core data
        firebaseModel.loadTopic()
        
        if let userCore = model.findAccountByUidCore(uid!) {
            let account = Account(uid: userCore.uid, username: userCore.username, emailAddress: userCore.emailAddress, phoneNumber: userCore.phoneNumber, isPremium: false)
            self.model.addUserAccount(account)
            if let profileCore = model.findProfileByUidCore(uid!){
                let profile = Profile(dateOfBirth: profileCore.dateOfBirth, gender: profileCore.gender, citizenship: profileCore.citizenship, nationality: profileCore.nationality, dateCreated: profileCore.dateCreated)
                profile.photo = profileCore.profileImage
                self.model.addUserProfile(account, profile: profile)
            }
            self.goToAnswersPage()
        }
        else
        {
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
                        print("profile retrieved")
                        
                        self.model.addUserProfile(account, profile: profile)
                        
                        self.firebaseModel.getProfileImage(account.uid, image: { (image) in
                            print("profile image retrieved")
                            self.model.addUserProfileImage( image!)
                            self.model.addProfileImageCore(account.uid, image: image!)
                            if let det = self.delegate {
                                det.fetchCurrentUserImageComplete()
                            }
                        })
                    }
                })
                
                self.goToAnswersPage()
            })

        }
        
    }
    
    func goToAnswersPage() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBar") as! UITabBarController
        viewController.selectedIndex = 2
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.window?.rootViewController = viewController
    }
}
