//
//  PublicQCell.swift
//  pPoll
//
//  Created by syle on 9/09/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class PublicQCell: UITableViewCell {
    
    @IBOutlet weak var ownerImage: UIImageView!
    
    @IBOutlet weak var newResponesLabel: UILabel!
    @IBOutlet weak var questionName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var questionDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ownerImage.layer.cornerRadius = CGRectGetHeight(ownerImage.bounds)/2.0
        ownerImage.clipsToBounds = true
    }
    
    func setup() {
        ownerImage.layer.borderColor = UIColor.blackColor().CGColor
        ownerImage.layer.borderWidth = 5
        ownerImage.layer.masksToBounds = true
        
        ownerImage.layer.cornerRadius = CGRectGetHeight(ownerImage.bounds)/2.0
      //  ownerImage.clipsToBounds = true
    }
    
    func setUpNewResponsd(r:Int) {
        if r == 0 {
            newResponesLabel.hidden = true
        }else{
            newResponesLabel.hidden = false
            newResponesLabel.text = String(r)
            let size:CGFloat = 25.0 // 35.0 chosen arbitrarily

            newResponesLabel.bounds = CGRectMake(0.0, 0.0, size, size)
            newResponesLabel.layer.cornerRadius = CGRectGetHeight(newResponesLabel.bounds)/2.0
            newResponesLabel.textColor = UIColor.whiteColor()
            newResponesLabel.layer.backgroundColor = UIColor(red: 83/255, green: 216/255, blue: 212/255, alpha:1.0).CGColor
        }
    }
}
