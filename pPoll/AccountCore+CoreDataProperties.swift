//
//  AccountCore+CoreDataProperties.swift
//  pPoll
//
//  Created by syle on 14/10/2016.
//  Copyright © 2016 syle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension AccountCore {

    @NSManaged var uid: String
    @NSManaged var username: String
    @NSManaged var phoneNumber: String
    @NSManaged var isPremium: NSNumber
    @NSManaged var emailAddress: String

}
