//
//  PulbicQuestionCreationViewController.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase

class PublicQuestionCreationViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    lazy var ref = FIRDatabase.database().reference()
    
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance

    var topic: Topic!
    
    let answerOneImagePicker = UIImagePickerController()
    let answerTwoImagePicker = UIImagePickerController()
    
    @IBOutlet weak var questionContent: UITextField!
    @IBOutlet weak var answerOneButton: UIButton!
    @IBOutlet weak var answerOneContent: UITextField!
    @IBOutlet weak var answerTwoButton: UIButton!
    @IBOutlet weak var answerTwoContent: UITextField!
    @IBOutlet weak var topicNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionContent.delegate = self
        answerOneContent.delegate = self
        answerTwoContent.delegate = self
        
        answerOneButton.layer.cornerRadius = answerOneButton.frame.size.width / 2
        answerOneButton.clipsToBounds = true
        
        answerTwoButton.layer.cornerRadius = answerTwoButton.frame.size.width / 2
        answerTwoButton.clipsToBounds = true
        
        answerOneImagePicker.delegate = self
        answerTwoImagePicker.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createQuestion(sender: AnyObject) {
        let textPresent = answerOneContent.text != "" || answerTwoContent.text != ""
        let imagePresent = answerOneButton.currentBackgroundImage != UIImage(named: "placeholder") || answerTwoButton.currentBackgroundImage != UIImage(named: "placeholder")
        
        let textBothPresent = answerOneContent.text != "" && answerTwoContent.text != ""
        let imagesBothPresent = answerOneButton.currentBackgroundImage != UIImage(named: "placeholder") && answerTwoButton.currentBackgroundImage != UIImage(named: "placeholder")
        
        let bothImageText = textBothPresent && imagesBothPresent
        let justText = textBothPresent && !imagePresent
        let justImage = imagesBothPresent && !textPresent
        
        if questionContent.text != "" && (bothImageText || (!bothImageText && justText) || ((!bothImageText && justImage))) {
            let questionText = questionContent.text
            
            let currentDate = NSDate()
            let calender = NSCalendar.currentCalendar()
            let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
            
            let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
            
            let question = Question(ID: "1234", content: questionText!, date: date, owner: model.user.uid)
            
            if bothImageText {
                let answerOneText = answerOneContent.text
                let answerTwoText = answerTwoContent.text
                
                let answerOneImage = answerOneButton.currentBackgroundImage
                let answerTwoImage = answerTwoButton.currentBackgroundImage
                
                let answerOne = Answer(id: "1234", text: answerOneText!, photo: answerOneImage!)
                let answerTwo = Answer(id: "1235", text: answerTwoText!, photo: answerTwoImage!)
                
                question.answers.append(answerOne)
                question.answers.append(answerTwo)
            }
            else if justText {
                let answerOneText = answerOneContent.text
                let answerTwoText = answerTwoContent.text
                
                let answerOne = Answer(id: "1234", text: answerOneText!)
                let answerTwo = Answer(id: "1235", text: answerTwoText!)
                
                question.answers.append(answerOne)
                question.answers.append(answerTwo)
            }
            else {
                let answerOneImage = answerOneButton.currentBackgroundImage
                let answerTwoImage = answerTwoButton.currentBackgroundImage
                
                let answerOne = Answer(id: "1234", photo: answerOneImage!)
                let answerTwo = Answer(id: "1235", photo: answerTwoImage!)
                
                question.answers.append(answerOne)
                question.answers.append(answerTwo)
            }
            
            firebaseModel.createPublicQuestion(question, topic: topic)
        }
    }
    
    @IBAction func selectAnswerOneImage(sender: AnyObject) {
        answerOneImagePicker.allowsEditing = false
        answerOneImagePicker.sourceType = .PhotoLibrary
        
        presentViewController(answerOneImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectAnswerTwoImage(sender: AnyObject) {
        answerTwoImagePicker.allowsEditing = false
        answerTwoImagePicker.sourceType = .PhotoLibrary
        
        presentViewController(answerTwoImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func unwindToPublicQuestionCreation (segue : UIStoryboardSegue) {
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if picker == answerOneImagePicker {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                answerOneButton.setBackgroundImage(pickedImage, forState: .Normal)
            }
        }
        else {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                answerTwoButton.setBackgroundImage(pickedImage, forState: .Normal)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 83/255, green: 216/255, blue: 212/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        header.alpha = 0.5 //make the header transparent
    }
}