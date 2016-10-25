//
//  GroupQuestionViewController.swift
//  pPoll
//
//  Created by Nath on 9/6/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit

class GroupQuestionCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    let answerOneImagePicker = UIImagePickerController()
    let answerTwoImagePicker = UIImagePickerController()
    
    var group: Group!
    
    @IBOutlet weak var questionContent: UITextField!
    @IBOutlet weak var answerOneButton: UIButton!
    @IBOutlet weak var answerOneContent: UITextField!
    @IBOutlet weak var answerTwoButton: UIButton!
    @IBOutlet weak var answerTwoContent: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerOneButton.layer.cornerRadius = answerOneButton.frame.size.width / 2
        answerOneButton.clipsToBounds = true
        
        answerTwoButton.layer.cornerRadius = answerTwoButton.frame.size.width / 2
        answerTwoButton.clipsToBounds = true
        
        answerOneImagePicker.delegate = self
        answerTwoImagePicker.delegate = self
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
            
            for member in group.members {
                let response = Response(owner: member.uid, answer: "TBA", date: date)
                question.responses.append(response)
            }
            
            firebaseModel.createGroupQuestion(question.content, answers: question.answers, responses: question.responses, owner: question.owner, group: group)
            
            performSegueWithIdentifier("Group Questions", sender: self)
        }
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
}
