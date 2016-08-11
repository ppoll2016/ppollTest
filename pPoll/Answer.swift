//
//  Answer.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Answer {
    var text : String!
    var photo : String!
    
    // Text Only
    init (text : String) {
        self.text = text
    }
    
    // Image Only
    init (photo : String) {
        self.photo = photo
    }
    
    // Both
    init (text : String, photo : String) {
        self.text = text
        self.photo = photo
    }
}