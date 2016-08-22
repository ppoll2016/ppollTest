//
//  Model.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit

class Model {
    private struct Static {
        static var instance: Model?
    }
    
    class var sharedInstance: Model {
        if (Static.instance == nil) {
            Static.instance = Model()
        }
        
        return Static.instance!
    }
    
    init () {
        populateData()
    }
    
    var user : Account!
    var accounts : [Account]!
    var groups : [Group]!
    var questions : [Question]!
    var topics : [Topic]!
    
    // Temp method to populate test data
    func populateData () {
        // Test Accounts
        accounts = [Account]()
        
        let account = Account(username: "User1", password: "123", emailAddress: "123", isAdmin: false)
        let account2 = Account(username: "User2", password: "123", emailAddress: "123", isAdmin: false)
        let account3 = Account(username: "User3", password: "123", emailAddress: "123", isAdmin: false)

        user = account
        
        accounts.append(account2)
        accounts.append(account3)
        
        // Test Topics
        topics = [Topic]()
        
        let topic  = Topic (name: "Automotive", description: "This is a car topic", photo: "placeholder")
        
        topics.append(topic)
        
        // Test Groups
        groups = [Group]()
        
        let group = Group (name: "Cars Club", owner: user, description: "This is a cars club", photo: UIImage(named: "placeholder")!, isPublic: false)
        let group2 = Group (name: "Flower Club", owner: user, description: "This is a cars club", photo: UIImage(named: "placeholder")!, isPublic: false)
        
        group.members.append(account2)
        group.members.append(account3)
        
        group.topics.append(topic)
        
        groups.append(group)
        groups.append(group2)
    }
}