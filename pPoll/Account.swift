//
//  Account.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Account : Equatable {
    var uid : String
    var username : String
    var emailAddress : String
    var phoneNumber : String
    var isPremium : Bool
    var profile : Profile!
    var groups = [Group]()
    var questions = [Question]()
    var contacts = [Account]()
    var orderValue: Int!
    
    init (uid : String, username : String, emailAddress : String,phoneNumber:String ,isPremium : Bool) {
        self.uid = uid
        self.username = username
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.isPremium = isPremium
    }
    
    init (uid: String, snapshot: [String: AnyObject]) {
        self.uid = uid
        self.username = snapshot["username"] as! String
        self.emailAddress = snapshot["email"] as! String
        
        let number = snapshot["phoneNumber"] as? String
        if  number != nil {
            self.phoneNumber = number!
        }
        else {
            self.phoneNumber = ""
        }
        
        self.isPremium = snapshot["isPremium"] as! Bool
    }
}


func ==(lhs : Account, rhs : Account) -> Bool {
    return lhs.uid == rhs.uid
}