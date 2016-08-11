//
//  Question.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Question {
    var ID : String
    var content : String
    var date : String
    var owner : Account!
    var topics : Dictionary<String, Topic>
    var group : Group!
    var isPublic : Bool
    var answers : [Answer]
    var response : Dictionary<String, Response>!
    
    // User question - can be public or private
    init (ID : String, content : String, date : String, owner : Account, topics : Dictionary<String, Topic>, isPublic : Bool, answers : [Answer]) {
        self.ID = ID
        self.content = content
        self.date = date
        self.owner = owner
        self.topics = topics
        self.isPublic = isPublic
        self.answers = answers
    }
    
    // Group Question - can be public or private
    init (ID : String, content : String, date : String, topics : Dictionary<String, Topic>, group : Group, isPublic : Bool, answers : [Answer])  {
        self.ID = ID
        self.content = content
        self.date = date
        self.group = group
        self.topics = topics
        self.isPublic = isPublic
        self.answers = answers
    }
    
    // Public pPoll Question - can only public
    init (ID : String, content : String, date : String, topics : Dictionary<String, Topic>, answers : [Answer])  {
        self.ID = ID
        self.content = content
        self.date = date
        self.topics = topics
        self.isPublic = true
        self.answers = answers
    }
}