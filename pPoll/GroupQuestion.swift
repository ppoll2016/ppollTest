//
//  GroupQuestion.swift
//  pPoll
//
//  Created by Nath on 8/25/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit
import Firebase

class GroupQuestion : Question {
    var group : Group
    
    init(ID: String, content: String, date: String, owner: String, group : Group) {
        self.group = group
        
        super.init(ID: ID, content: content, date: date, owner: owner)
        self.isPublic = false
    }
    
    init(ID: String, snapShot: [String: AnyObject], group : Group) {
        self.group = group
        
        super.init(ID: ID, snapShot: snapShot)
        self.isPublic = false
    }
}
