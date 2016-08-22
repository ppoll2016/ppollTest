//
//  Group.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit

class Group {
    var name : String
    var owner : Account
    var description : String
    var members : [Account]
    var topics : [Topic]!
    var photo : UIImage
    var isPublic : Bool
    
    init (name : String, owner : Account, description : String, photo : UIImage, isPublic : Bool) {
        self.name = name
        self.owner = owner
        self.description = description
        self.photo = photo
        self.isPublic = isPublic
        self.members = [Account]()
        self.topics = [Topic]()
    }
}