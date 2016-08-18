//
//  SignUpController.swift
//  pPoll
//
//  Created by 薛晨 on 15/08/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {
    
    
    @IBOutlet weak var RegisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RegisterButton.layer.cornerRadius  = 10
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
