//
//  Account.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Account : Equatable {
    var username : String
    var password : String
    var emailAddress : String
    var isAdmin : Bool
    var profile : Profile!
    var groups : [Group]
    
    init (username : String, password : String, emailAddress : String, isAdmin : Bool) {
        self.username = username
        self.password = password
        self.emailAddress = emailAddress
        self.isAdmin = isAdmin
        self.groups = [Group]()
    }
}


func ==(lhs : Account, rhs : Account) -> Bool {
    return lhs.username == rhs.username
}