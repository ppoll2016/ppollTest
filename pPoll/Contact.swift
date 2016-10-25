//
//  Contact.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class Contact {
    var name: String
    var number: String
    var uid: String!
    var photo: UIImage!
    
    init (name: String, number: String) {
        self.name = name
        self.number = number
        self.uid = ""
    }
    
    init (name: String, number: String, uid: String) {
        self.name = name
        self.number = number
        self.uid = uid
    }
}