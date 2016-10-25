//
//  AnswerPageCell.swift
//  pPoll
//
//  Created by James McKay on 17/10/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Foundation

class AnswerPageCell: CircularTableViewCell{
    var resultsVC: GroupQuestionResultViewController!
    var number: String!
    
    @IBOutlet weak var reminderButton: UIButton!
    
    
    @IBAction func buttonClicked(sender: AnyObject) {
        resultsVC.presentMessageThing(number)
    }
}