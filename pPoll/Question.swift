//
//  Question.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import Firebase

class Question : Equatable {
    var ID : String
    var content : String
    var date : String
    var owner : String!
    var isPublic : Bool
    var answers : [Answer]!
    var responses : [Response]!
    var responseNo: Int!
    var members: String!
    
    init (ID : String, content : String, date : String, owner : String) {
        self.ID = ID
        self.content = content
        self.date = date
        self.owner = owner
        self.isPublic = false
        self.responses = [Response]()
        self.answers = [Answer]()
        self.members = ""
    }
    
    init (ID : String, snapShot : [String: AnyObject]) {
        self.ID = ID
        self.content = snapShot["content"] as! String
        self.date = snapShot["date"] as! String
        self.owner = snapShot["owner"] as! String
        self.isPublic = false
        self.responses = [Response]()
        self.answers = [Answer]()
        self.members = ""
    }
}

func ==(lhs : Question, rhs : Question) -> Bool {
    return lhs.ID == rhs.ID
}

