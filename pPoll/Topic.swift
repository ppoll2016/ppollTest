//
//  Topic.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit

class Topic : Equatable {
    var name : String
    var photo : UIImage!
    
    init (name : String) {
        self.name = name
    }
}

func ==(lhs : Topic, rhs : Topic) -> Bool {
    return lhs.name == rhs.name
}