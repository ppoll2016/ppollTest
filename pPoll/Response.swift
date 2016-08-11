//
//  Response.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Response {
    var owner : Account
    var answer : Answer
    var date : String
    
    init (owner : Account, answer : Answer, date : String) {
        self.owner = owner
        self.answer = answer
        self.date = date
    }
}