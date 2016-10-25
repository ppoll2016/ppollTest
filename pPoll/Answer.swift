//
//  Answer.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class Answer: Equatable {
    var id: String
    var text: String!
    var photo: UIImage!
    var respondsNum: Int = 0
    
    // Text Only
    init (id: String, text : String) {
        self.id = id
        self.text = text
    }
    
    // Image Only
    init (id: String, photo : UIImage) {
        self.id = id
        self.photo = photo
    }
    
    // Both
    init (id: String, text : String, photo : UIImage) {
        self.id = id
        self.text = text
        self.photo = photo
    }
    
    func respondAddone(){
        
    }
}

func ==(lhs: Answer, rhs: Answer) -> Bool {
    return lhs.id == rhs.id
}