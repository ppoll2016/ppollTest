//
//  Response.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Response : Equatable {
    var owner: String
    var answer: String
    var date: String
    
    init (owner: String, answer: String, date: String) {
        self.owner = owner
        self.answer = answer
        self.date = date
    }
    
    init (owner: String, snapshot: [String: AnyObject]) {
        self.owner = owner
        self.answer = snapshot["answer"] as! String
        self.date = snapshot["date"] as! String
    }
}

func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.owner == rhs.owner
}