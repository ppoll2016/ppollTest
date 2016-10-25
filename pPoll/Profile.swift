//
//  Profile.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class Profile {
    var dateOfBirth : String
    var gender : String
    var citizenship : String
    var nationality : String
    var photo : UIImage
    var dateCreated : String
    
    init (dateOfBirth : String, gender : String, citizenship : String, nationality : String, dateCreated : String) {
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.citizenship = citizenship
        self.nationality = nationality
        self.dateCreated = dateCreated
        self.photo = UIImage(named: "placeholder")!
    }
    
    init (snapshot: [String: AnyObject]) {
        self.dateOfBirth = snapshot["dateOfBirth"] as! String
        self.gender = snapshot["gender"] as! String
        self.citizenship = snapshot["citizenship"] as! String
        self.nationality = snapshot["nationality"] as! String
        self.dateCreated = snapshot["dateCreated"] as! String
        self.photo = UIImage(named: "placeholder")!
    }
}