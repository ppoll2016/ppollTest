//
//  Group.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Group: NSObject {
    static let MAX_MEMBER_NO = 10
    
    var ID : String
    var name : String
    var owner : String
    var members = [Account]()
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

func ==(lhs : Group, rhs : Group) -> Bool {
    return lhs.ID == rhs.ID
}
