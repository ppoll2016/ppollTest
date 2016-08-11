//
//  Group.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Group {
    var name : String
    var owner : Account
    var description : String
    var members : Dictionary<String, Account>!
    var topics : Dictionary<String, Topic>!
    var photo : String
    var isPublic : Bool
    
    init (name : String, owner : Account, description : String, photo : String, isPublic : Bool) {
        self.name = name
        self.owner = owner
        self.description = description
        self.photo = photo
        self.isPublic = isPublic
    }
}