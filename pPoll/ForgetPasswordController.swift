//
//  ForgetPasswordController.swift
//  pPoll
//
//  Created by 薛晨 on 15/08/2016.
//  Copyright © 2016 syle. All rights reserved.
//


import UIKit

class ForgetPasswordController: UIViewController {
    
    
    @IBOutlet weak var SendCodeButton: UIButton!
    @IBOutlet weak var ResetButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        SendCodeButton.layer.cornerRadius  = 10
        ResetButton.layer.cornerRadius  = 10
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}