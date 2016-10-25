//
//  InviteTableViewCell.swift
//  pPoll
//
//  Created by Nath on 10/4/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import MessageUI

class InviteTableViewCell: UITableViewCell, MFMessageComposeViewControllerDelegate {
    var number: String!
    var index: Int!
    var addPCViewController: AddPhoneContactViewController!
    var invited = false
    var pPollColour: UIColor!
    
    @IBOutlet weak var circularLabel: UILabel!
    @IBOutlet weak var circularImage: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pPollColour = inviteButton.backgroundColor
    }
    
    @IBAction func inviteTopPoll(sender: AnyObject) {
        if !invited {
            print("Invited \(number) to join pPoll")
            
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Check out the pPoll app on the app store"
            messageVC.recipients = [number]
            messageVC.messageComposeDelegate = self
            
            addPCViewController.presentViewController(messageVC, animated: false, completion: nil)
            
            inviteButton.setTitle("Uninvite", forState: .Normal)
            inviteButton.backgroundColor = UIColor.redColor()
            
            // Add to invite list
            addPCViewController.selectedContacts[index] = true
            invited = true
        }
        else {
            print("Uninvited \(number) to join pPoll")
            
            inviteButton.setTitle("Invite", forState: .Normal)
            inviteButton.backgroundColor = pPollColour
            
            // Remove from invite list
            addPCViewController.selectedContacts[index] = false
            invited = false
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case MessageComposeResultCancelled:
            print("Message cancelled")
            addPCViewController.dismissViewControllerAnimated(true, completion: nil)
            break
        case MessageComposeResultFailed:
            print("Message failed")
            addPCViewController.dismissViewControllerAnimated(true, completion: nil)
            break
        case MessageComposeResultSent:
            print("Message sent")
            addPCViewController.dismissViewControllerAnimated(true, completion: nil)
            break
        default:
            break
        }
    }
}