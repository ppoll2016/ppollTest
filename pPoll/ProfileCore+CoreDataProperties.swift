//
//  ProfileCore+CoreDataProperties.swift
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
import UIKit

extension ProfileCore {

    @NSManaged var dateOfBirth: String
    @NSManaged var gender: String
    @NSManaged var citizenship: String
    @NSManaged var nationality: String
    @NSManaged var dateCreated: String
    @NSManaged var uid: String
    @NSManaged var profileImage: UIImage

}
