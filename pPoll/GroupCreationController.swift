//
//  GroupCreationController.swift
//  pPoll
//
//  Created by Nath on 8/13/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import Foundation
import UIKit

class GroupCreationController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var publicSwitch: UISwitch!

    let imagePicker = UIImagePickerController()
    var selectedImage : UIImage!
    var selectedAccounts : [Bool]!
    var selectedTopics : [Bool]!
    let model = Model.sharedInstance
    
    var removeNavStack : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the selected arrays if required
        if selectedAccounts == nil {
            selectedAccounts = [Bool]()
            
            for _ in 0...model.accounts.count {
                selectedAccounts.append(false)
            }
        }
        
        if selectedTopics == nil {
            selectedTopics = [Bool]()
            
            for _ in 0...model.topics.count {
                selectedTopics.append(false)
            }
        }
        
        selectedImage = UIImage(named: "placeholder")
        
        imagePicker.delegate = self
    }
    
    @IBAction func selectGroupPhoto(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.selectedImage = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        let addPersonTVC = self.storyboard!.instantiateViewControllerWithIdentifier("AddPersonTVC") as! AddPersonTableViewController
        let navController = UINavigationController(rootViewController: addPersonTVC)
        addPersonTVC.checked = selectedAccounts
        addPersonTVC.groupCreationController = self
        self.presentViewController(navController, animated: false, completion: nil)
    }
    
    @IBAction func addTopic(sender: AnyObject) {
        let addTopicTVC = self.storyboard!.instantiateViewControllerWithIdentifier("AddTopicTVC") as! AddTopicTableViewController
        let navController = UINavigationController(rootViewController: addTopicTVC)
        addTopicTVC.checked = selectedTopics
        addTopicTVC.groupCreationController = self
        self.presentViewController(navController, animated: false, completion: nil)
    }
    
    @IBAction func createGroup(sender: AnyObject) {
        if nameTextField.text != "" && descriptionTextField.text != "" {
            let name = nameTextField.text
            let description = descriptionTextField.text
            
            var members = [Account]()
            for index in 0...selectedAccounts.count - 1 {
                if selectedAccounts[index] {
                    members.append(model.accounts[index])
                }
            }
            
            var topics = [Topic]()
            for index in 0...selectedTopics.count - 1 {
                if selectedTopics[index] {
                    topics.append(model.topics[index])
                }
            }
            
            let isPublic = publicSwitch.selected
            
            let createdGroup = Group(name: name!, owner: model.user, description: description!, photo: selectedImage, isPublic: isPublic)
            createdGroup.members = members
            createdGroup.topics = topics
            
            model.groups.append(createdGroup)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}