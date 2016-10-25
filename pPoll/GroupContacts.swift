//
//  GroupContacts.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupContacts: NSObject {
    static let MAX_MEMBER_NO = 10
    
    var ID : String
    var name : String
    var owner : String
    var contacts = [Contact]()
    var questions = [Question]()
    var photo : UIImage!
    
    init (ID : String, name : String, owner : String) {
        self.ID = ID
        self.name = name
        self.owner = owner
    }
    
    init (ID : String, snapShot : [String:AnyObject]) {
        self.ID = ID
        self.name = snapShot["name"] as! String
        self.owner = snapShot["owner"] as! String
    }
}

func ==(lhs : GroupContacts, rhs : GroupContacts) -> Bool {
    return lhs.ID == rhs.ID
}
