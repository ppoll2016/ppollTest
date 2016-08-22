//
//  Topic.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit

class Topic {
    var name : String
    var description : String
    var photo : UIImage
    
    init (name : String, description : String, photo : String) {
        self.name = name
        self.description = description
        self.photo = UIImage(named: photo)!
    }
}