//
//  GroupDetailsViewController.swift
//  pPoll
//
//  Created by Nath on 8/14/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit

class GroupDetailsViewController : UIViewController {
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var topicsButton: UIButton!
    
    var group : Group!
    var model : Model = Model.sharedInstance
    
    override func viewDidLoad() {
        // Set group fields
        groupImage.image = group.photo
        groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
        groupImage.clipsToBounds = true
        
        nameLabel.text = group.name
        ownerLabel.text = group.owner.username
        descriptionLabel.text = group.description
        memberButton.setTitle(String(group.members.count) + " members", forState: .Normal)
        topicsButton.setTitle(String(group.topics.count) + " topics", forState: .Normal)
    }
    
    @IBAction func joinGroup(sender: AnyObject) {
        model.user.groups.append(group)
        model.groups[model.groups.indexOf({ $0.name == group.name })!].members.append(model.user)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
