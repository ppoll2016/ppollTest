//
//  PremiumQuestion.swift
//  pPoll
//
//  Created by Nath on 8/25/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit

class PremiumQuestion : Question {
    var topics : [Topic]!
    
    init(ID: String, content: String, date: String, owner: String, topics : [Topic]) {
        self.topics = topics
        
        super.init(ID: ID, content: content, date: date, owner: owner)
        self.isPublic = true
    }
    
    init(ID: String, snapshot: [String: AnyObject]) {
        super.init(ID: ID, snapShot: snapshot)
        self.isPublic = true
    }
}
