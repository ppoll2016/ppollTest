//
//  GroupQuestionCore+CoreDataProperties.swift
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

extension GroupQuestionCore {

    @NSManaged var groupid: String
    @NSManaged var content: String
    @NSManaged var date: String
    @NSManaged var id: String
    @NSManaged var isPublic: NSNumber
    @NSManaged var owner: String
    @NSManaged var responseNo: NSNumber

}
