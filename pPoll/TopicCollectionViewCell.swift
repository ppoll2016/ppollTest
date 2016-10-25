//
//  TopicCell.swift
//  pPoll
//
//  Created by 薛晨 on 13/10/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class TopicCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.shadowRadius = 4.0
            imageView.layer.shadowOpacity = 0.5
            imageView.layer.shadowOffset = CGSize.zero
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        }
    }
    
}