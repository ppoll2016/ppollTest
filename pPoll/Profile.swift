//
//  Profile.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation

class Profile {
    var firstName : String
    var lastName : String
    var dateOfBirth : String
    var gender : String
    var citizenship : String
    var nationality : String
    var photo : String!
    var dateCreated : String
    var premium : Bool
    
    init (firstName : String, lastName : String, dateOfBirth : String, gender : String, citizenship : String, nationality : String, dateCreated : String) {
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.citizenship = citizenship
        self.nationality = nationality
        self.dateCreated = dateCreated
        self.premium = false;
    }
}