//
//  SelectGroupTableViewCell.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class SelectGroupTableViewCell: UITableViewCell {
    let firebaseModel = ModelFirebase.sharedInstance
    
    var index: Int!
    var groupID: String!
    var uid: String!
    
    var selectGroupVC: SelectGroupViewController!
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!

    @IBAction func editGroup(sender: AnyObject) {
        selectGroupVC.editIndex = index
    }
    
    @IBAction func leaveGroup(sender: AnyObject) {
        firebaseModel.leaveGroup(groupID, uid: uid)
    }
}