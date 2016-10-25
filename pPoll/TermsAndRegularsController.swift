//
//  TermsAndRegularsController.swift
//  pPoll
//
//  Created by WangXin on 16/10/3.
//  Copyright © 2016年 syle. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TermsAndRegularsController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    func initUI(){
        self.view.addBackground()
        
    }
    
    @IBAction func declineClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}