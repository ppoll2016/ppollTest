//
//  TopicCore+CoreDataProperties.swift
//  pPoll
//
//  Created by 薛晨 on 21/10/2016.
//  Copyright © 2016 syle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import UIKit

extension TopicCore {

    @NSManaged var name: String
    @NSManaged var topicImage: UIImage

}
