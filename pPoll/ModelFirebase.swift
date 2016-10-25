//
//  ModelFirebase.swift
//  pPoll
//
//  Created by Nath on 8/21/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import Firebase

class ModelFirebase {
    let model = Model.sharedInstance
    
    struct Recent {
        var id: String
        var order: Int
        var responseNo: Int
        var type: String
    }
    
    let realtimeDBRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://ppoll-1d745.appspot.com")
    
    private struct Static {
        static var instance: ModelFirebase?
    }
    
    class var sharedInstance: ModelFirebase {
        if (Static.instance == nil) {
            Static.instance = ModelFirebase()
        }
        
        return Static.instance!
    }
    
    init() {
        
    }
    
    // MARK: Create Test Data Methods
    func createTestData() {
        createTestAccounts()
    }
    
    func createTestAccounts() {
        let accountRef = realtimeDBRef.child("Accounts").child("Qyyjy0034BhWlUPlTuG5GVCqUJ43").child("contacts")
        
        for index in 0...5 {
            let account = Account(uid: "testID" + String(index), username: "testuser" + String(index), emailAddress: "testuser" + String(index) + "@test.com",phoneNumber: "1233445", isPremium: false)
            
            let accountsArray = ["username": account.username, "email": account.emailAddress, "isPremium": account.isPremium]
            
            realtimeDBRef.child("Accounts").child(account.uid).setValue(accountsArray)
            accountRef.updateChildValues([account.uid: true])
        }
    }
    
    // MARK: Create Methods
    func createGroup(group: Group) -> String {
        var ID: String
        if group.ID == "" {
            ID = realtimeDBRef.child("Groups").childByAutoId().key
        }
        else {
            ID = group.ID
        }

        realtimeDBRef.child("GroupMembers").child(ID).setValue(nil)
        for member in group.members {
            // Add the group as a child for each of the members
            realtimeDBRef.child("GroupMembers").child(ID).updateChildValues([member.uid: true])
            realtimeDBRef.child("AccountGroups").child(member.uid).updateChildValues([ID: true])
        }
        
        let groupArray = ["name": group.name, "owner": group.owner]
        realtimeDBRef.child("Groups").child(ID).setValue(groupArray)
        
        // Upload GroupImage
        let image = UIImageJPEGRepresentation(group.photo, 0.1)
        
        let imageRef = storageRef.child("images/groups/" + group.ID + ".jpg")
        
        let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
            if error != nil {
                print("Failed Group Image Upload")
            }
        }
        
        return ID
    }
    
    func createGroupContacts(group: GroupContacts) -> String {
        var ID: String
        if group.ID == "" {
            ID = realtimeDBRef.child("Groups").childByAutoId().key
        }
        else {
            ID = group.ID
        }
        
        realtimeDBRef.child("GroupMembers").child(ID).setValue(nil)
        for contact in group.contacts {
            // Add the group as a child for each of the members
            if contact.uid != "" {
                realtimeDBRef.child("GroupMembers").child(ID).updateChildValues([contact.uid: true])
                realtimeDBRef.child("AccountGroups").child(contact.uid).updateChildValues([ID: true])
            }
            else {
                realtimeDBRef.child("GroupMembers").child(ID).updateChildValues([contact.number: true])
            }
        }
        
        let groupArray = ["name": group.name, "owner": group.owner]
        realtimeDBRef.child("Groups").child(ID).setValue(groupArray)
        
        // Upload GroupImage
        let image = UIImageJPEGRepresentation(group.photo, 0.1)
        
        let imageRef = storageRef.child("images/groups/" + ID + ".jpg")
        
        let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
            if error != nil {
                print("Failed Group Image Upload")
            }
        }
        
        return ID
    }
    
    func createGroupQuestion(content: String, answers: [Answer], responses: [Response], owner: String, group: Group) {
        let ID = realtimeDBRef.child("GroupQuestions").childByAutoId().key
        
        let currentDate = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
        
        let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
        
        let question = GroupQuestion(ID: ID, content: content, date: date, owner: owner, group: group)
        
        // Add the answers to the firebase DB
        for index in 0...answers.count - 1 {
            let answer = answers[index]
            var answersArray = [String: AnyObject]()
            
            if answer.text != nil {
                answersArray["text"] = answer.text
            }
                
            if answer.photo != nil {
                answersArray["photo"] = true
                
                // Upload AnswerImage
                let image = UIImageJPEGRepresentation(answer.photo, 0.1)
                
                let imageRef = storageRef.child("images/answers/" + question.ID + "/" + answer.id + ".jpg")
                
                let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
                    if error != nil {
                        print("Failed Answer Image Upload")
                    }
                }
            }
            
            answersArray["responses"] = 0
            realtimeDBRef.child("Answers").child(ID).child(answer.id).updateChildValues(answersArray)
        }
        
        // Create a response for every member
        for response in responses {
            var responseArray = [String: AnyObject]()
            
            responseArray["answer"] = response.answer
            responseArray["date"] = response.date
            
            realtimeDBRef.child("Responses").child(ID).child(response.owner).updateChildValues(responseArray)
            realtimeDBRef.child("Recent").child(response.owner).updateChildValues([ID:"GroupQuestions"])
        }
        
        let questionArray = ["content": question.content, "date": question.date, "owner": owner, "groupID": group.ID]
        realtimeDBRef.child("GroupQuestions").child(ID).updateChildValues(questionArray)
    }
    
    func createGroupContactsQuestion(content: String, answers: [Answer], responses: [Response], owner: String, group: GroupContacts) -> String {
        let ID = realtimeDBRef.child("GroupQuestions").childByAutoId().key
        
        let currentDate = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
        
        let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
        
        let question = Question(ID: ID, content: content, date: date, owner: owner)
        
        // Add the answers to the firebase DB
        for index in 0...answers.count - 1 {
            let answer = answers[index]
            var answersArray = [String: AnyObject]()
            
            if answer.text != nil {
                answersArray["text"] = answer.text
            }
            
            if answer.photo != nil {
                answersArray["photo"] = true
                
                // Upload AnswerImage
                let image = UIImageJPEGRepresentation(answer.photo, 0.1)
                
                let imageRef = storageRef.child("images/answers/" + question.ID + "/" + answer.id + ".jpg")
                
                let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
                    if error != nil {
                        print("Failed Answer Image Upload")
                    }
                }
            }
            
            answersArray["responses"] = 0
            realtimeDBRef.child("Answers").child(ID).child(answer.id).updateChildValues(answersArray)
        }
        
        // Create a response for every member
        realtimeDBRef.child("GroupMembers").child(group.ID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in let groupMembersSnapshot = snapshot.value as! [String:AnyObject]
            for(key,_) in groupMembersSnapshot {
                var responseArray = [String: AnyObject]()
                
                responseArray["answer"] = "TBA"
                responseArray["date"] = question.date
                
                self.realtimeDBRef.child("Responses").child(ID).child(key).updateChildValues(responseArray)
                
                self.realtimeDBRef.child("Recent").child(key).child("order").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let order = snapshot.value as? Int
                    
                    if order != nil {
                        self.realtimeDBRef.child("Recent").child(key).child(ID).updateChildValues(["type":"Questions", "responseNo": 0, "order":order! - 1])
                        self.realtimeDBRef.child("Recent").child(key).updateChildValues(["order":order! - 1])
                    }
                    else {
                        self.realtimeDBRef.child("Recent").child(key).child(ID).updateChildValues(["type":"Questions", "responseNo": 0, "order":500])
                        self.realtimeDBRef.child("Recent").child(key).updateChildValues(["order":500])
                    }
                })
            }
        })
        
        let questionArray = ["content": question.content, "date": question.date, "owner": owner, "groupID": group.ID]
        realtimeDBRef.child("GroupQuestions").child(ID).updateChildValues(questionArray)
        
        return ID
    }
    
    func createPrivateQuestion(content: String, answers: [Answer], responses: [Response], owner: String) -> String {
        let ID = realtimeDBRef.child("PrivateQuestions").childByAutoId().key
        
        let currentDate = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Day, .Month, .Year], fromDate: currentDate)
        
        let date = String(components.day) + "-" + String(components.month) + "-" + String(components.year)
        
        let question = Question(ID: ID, content: content, date: date, owner: owner)
        
        // Add the answers to the firebase DB
        for index in 0...answers.count - 1 {
            let answer = answers[index]
            var answersArray = [String: AnyObject]()
            
            if answer.text != nil {
                answersArray["text"] = answer.text
            }
            
            if answer.photo != nil {
                answersArray["photo"] = true
                
                // Upload AnswerImage
                let image = UIImageJPEGRepresentation(answer.photo, 0.1)
                
                let imageRef = storageRef.child("images/answers/" + question.ID + "/" + answer.id + ".jpg")
                
                let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
                    if error != nil {
                        print("Failed Answer Image Upload")
                    }
                }
            }
            
            answersArray["responses"] = 0
            realtimeDBRef.child("Answers").child(ID).child(answer.id).updateChildValues(answersArray)
        }
        
        // Create a response for every member
        for response in responses {
            var responseArray = [String: AnyObject]()
            
            responseArray["answer"] = response.answer
            responseArray["date"] = response.date
            
            let uid = response.owner
            
            // Updating the order value
            realtimeDBRef.child("Recent").child(uid).child("order").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let order = snapshot.value as? Int
                
                if order != nil {
                    self.realtimeDBRef.child("Recent").child(response.owner).child(ID).updateChildValues(["type":"Questions", "responseNo": 1, "order":order! - 1])
                    self.realtimeDBRef.child("Recent").child(response.owner).updateChildValues(["order":order! - 1])
                }
                else {
                    self.realtimeDBRef.child("Recent").child(response.owner).child(ID).updateChildValues(["type":"Questions", "responseNo": 1, "order":500])
                    self.realtimeDBRef.child("Recent").child(response.owner).updateChildValues(["order":500])
                }
            })
            
            realtimeDBRef.child("Responses").child(ID).child(response.owner).updateChildValues(responseArray)
        }
        
        let questionArray = ["content": question.content, "date": question.date, "owner": owner]
        realtimeDBRef.child("PrivateQuestions").child(ID).updateChildValues(questionArray)
        
        return ID
    }
    
    func createPremiumQuestion(question: PremiumQuestion) {
        let ID = realtimeDBRef.child("PremiumQuestions").childByAutoId().key
        
        // Add the answers to the firebase DB
        for index in 0...question.answers.count - 1 {
            let answer = question.answers[index]
            var answersArray = [String: AnyObject]()
            
            if answer.text != nil {
                answersArray["text"] = answer.text
            }
            
            if answer.photo != nil {
                answersArray["photo"] = true
                
                // Upload AnswerImage
                let image = UIImageJPEGRepresentation(answer.photo, 0.1)
                
                let imageRef = storageRef.child("images/answers/" + question.ID + "/" + answer.id + ".jpg")
                
                let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
                    if error != nil {
                        print("Failed Answer Image Upload")
                    }
                }
            }
            
            answersArray["responses"] = 0
            realtimeDBRef.child("PremiumQuestionAnswers").child(ID).child(answer.id).updateChildValues(answersArray)
        }
        
        // Create the question topics
        for topic in question.topics {
            var topicsArray = [String: AnyObject]()
            
            topicsArray[topic.name] = true
            realtimeDBRef.child("PremiumQuestionTopics").child(ID).updateChildValues(topicsArray)
        }
        
        let questionArray = ["content": question.content, "date": question.date, "owner": question.owner]
        realtimeDBRef.child("PremiumQuestions").child(ID).updateChildValues(questionArray)
    }
    
    func createPublicQuestion(question: Question, topic: Topic) {
        let ID = realtimeDBRef.child("PublicQuestions").childByAutoId().key
        
        // Add the answers to the firebase DB
        for index in 0...question.answers.count - 1 {
            let answer = question.answers[index]
            var answersArray = [String: AnyObject]()
            
            if answer.text != nil {
                answersArray["text"] = answer.text
            }
            
            if answer.photo != nil {
                answersArray["photo"] = true
                
                // Upload AnswerImage
                let image = UIImageJPEGRepresentation(answer.photo, 0.1)
                
                let imageRef = storageRef.child("images/answers/" + question.ID + "/" + answer.id + ".jpg")
                
                let _ = imageRef.putData(image!, metadata: nil) { metadata, error in
                    if error != nil {
                        print("Failed Answer Image Upload")
                    }
                }
            }
            
            answersArray["responses"] = 0
            realtimeDBRef.child("Answers").child(ID).child(answer.id).updateChildValues(answersArray)
        }
        
        var topicsArray = [String: AnyObject]()
        
        topicsArray[topic.name] = true
        realtimeDBRef.child("PublicQuestionTopics").child(ID).updateChildValues(topicsArray)
        
        var questionTopicArray = [String: AnyObject]()
        
        questionTopicArray[ID] = true
        realtimeDBRef.child("TopicPublicQuestions").child(topic.name).updateChildValues(questionTopicArray)
        
        let questionArray = ["content": question.content, "date": question.date, "owner": question.owner]
        realtimeDBRef.child("PublicQuestions").child(ID).updateChildValues(questionArray)
    }
    
    func updatePhoneResponse(questionID: String, number: String) {
        realtimeDBRef.child("Responses").child(questionID).child(number).setValue(nil)
    }
    
    func updatePremiumQuestion(question: Question, index: Int){
        let num = question.answers[index].respondsNum + 1
        realtimeDBRef.child("PremiumQuestionAnswers").child(question.ID).child(question.answers[index].id).updateChildValues(["responses": num])
        
        let num2 = question.answers[index].respondsNum + 1
        realtimeDBRef.child("PremiumQuestionAnswers").child(question.ID).child(question.answers[index].id).updateChildValues(["responses": num])
    }
    
    func deleteGroup(group: Group) {
        // Remove the group from the members group list
        for member in group.members {
            realtimeDBRef.child("AccountGroups").child(member.uid).child(group.ID).setValue(nil)
        }
        
        realtimeDBRef.child("GroupQuestions").observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
                self.realtimeDBRef.child("GroupQuestionAnswers").child(snapshot.key).setValue(nil)
                self.realtimeDBRef.child("GroupQuestionResponses").child(snapshot.key).setValue(nil)
            })
        
        realtimeDBRef.child("GroupMembers").child(group.ID).setValue(nil)
        realtimeDBRef.child("Groups").child(group.ID).setValue(nil)
    }
    
    func deleteGroup(group: GroupContacts) {
        // Remove the group from the members group list
        for member in group.contacts {
            realtimeDBRef.child("AccountGroups").child(member.uid).child(group.ID).setValue(nil)
        }
        
        realtimeDBRef.child("GroupMembers").child(group.ID).setValue(nil)
        realtimeDBRef.child("Groups").child(group.ID).setValue(nil)
    }
    
    func leaveGroup(groupID: String, uid: String) {
        realtimeDBRef.child("AccountGroups").child(uid).child(groupID).setValue(nil)
        realtimeDBRef.child("GroupMembers").child(groupID).child(uid).setValue(nil)
    }

    func updateContacts(uid:String,contacts :[Account]){
        for contact in contacts {
            let contactsArray = [contact.uid: true]
            
            realtimeDBRef.child("AccountContacts").child(uid).updateChildValues(contactsArray)
        }
    }
    
    func updateAccountContacts(questionID: String, uid: String, contacts: [Contact], keys: [String]) {
        var modKeys = keys
        
        for contact in contacts {
            if contact.uid != nil {
                if modKeys.contains(contact.uid) {
                    if contact.number != "" {
                        realtimeDBRef.child("AccountContacts").child(uid).updateChildValues([contact.number:contact.name])
                        realtimeDBRef.child("QuestionMembers").child(questionID).updateChildValues([contact.number:contact.name])
                    }
                    else {
                        realtimeDBRef.child("AccountContacts").child(uid).updateChildValues([contact.uid:contact.name])
                        realtimeDBRef.child("QuestionMembers").child(questionID).updateChildValues([contact.uid:contact.name])
                    }

                    modKeys.removeAtIndex(modKeys.indexOf(contact.uid)!)
                }
                else if modKeys.contains(contact.number) {
                    realtimeDBRef.child("AccountContacts").child(uid).updateChildValues([contact.number:contact.name])
                    realtimeDBRef.child("QuestionMembers").child(questionID).updateChildValues([contact.number:contact.name])
                    modKeys.removeAtIndex(modKeys.indexOf(contact.number)!)
                }
            }
            else if keys.contains(contact.number) {
                realtimeDBRef.child("AccountContacts").child(uid).updateChildValues([contact.number:contact.name])
                realtimeDBRef.child("QuestionMembers").child(questionID).updateChildValues([contact.number:contact.name])
                modKeys.removeAtIndex(modKeys.indexOf(contact.number)!)
            }
        }
        
        for key in modKeys {
            realtimeDBRef.child("AccountContacts").child(uid).updateChildValues([key:key])
            realtimeDBRef.child("QuestionMembers").child(questionID).updateChildValues([key:key])
        }
    }
    
    func updatePublicpPollQuestionResponse(question: Question, response: Response) {
        let responseArray = ["answer": response.answer, "date": response.date]
        realtimeDBRef.child("Responses").child(question.ID).child(response.owner).setValue(responseArray)
    }
    
    func updateProfile(uid:String,profileArray:[String:String]){
        realtimeDBRef.child("Profiles").child(uid).updateChildValues(profileArray)
        //fetchProfile(uid);
        let profile = Profile(snapshot: profileArray)
        self.model.addUserProfile(self.model.findAccountByUid(uid)!, profile: profile)
        
    }
    
    func updateFaceBookProfile(uid:String,profileArray:[String:String]){
        realtimeDBRef.child("Profiles").child(uid).updateChildValues(profileArray)
    }
    
    func fetchProfile(uid:String){
        // Add profile
        realtimeDBRef.child("Profiles").child(uid).observeEventType(.Value, withBlock: { (snapshot) in let profileSnapshot = snapshot.value as? [String: AnyObject]
            if profileSnapshot != nil {
                let profile = Profile(snapshot: profileSnapshot!)
                print("profile retrieved")
                
                self.model.addUserProfile(self.model.findAccountByUid(uid)!,profile: profile)
                
                self.getProfileImage(uid, image: { (image) in
                    print("profile image retrieved")
                    self.model.addUserProfileImage( image!)
                })
            }
        })
    }
    
    func updateInterestedTopics(uid:String,interestedTopicArray:[String]){
        model.updateInterestedTopicArray(interestedTopicArray)
        var interestedTopicDic = [String:Bool]();
        for topic in interestedTopicArray{
            interestedTopicDic.updateValue(true, forKey: topic)
        }
        realtimeDBRef.child("InterestedTopic").child(uid).setValue(nil)
        realtimeDBRef.child("InterestedTopic").child(uid).updateChildValues(interestedTopicDic)
    }
    
    func uploadProfileImage(uid:String,image:UIImage){
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        let imageRef = storageRef.child("images/profiles/"+uid+".jpg")
        let _ = imageRef.putData(imageData!, metadata: nil) { metadata, error in
            if error != nil {
                print("Failed Profile Image Upload")
            }
        }
    }
    
    func updateGroupQuestionResponse(question: Question, response: Response, currentUID: String) {
        let responseArray = ["answer": response.answer, "date": response.date]
        realtimeDBRef.child("Responses").child(question.ID).child(response.owner).setValue(responseArray)
        
        for response in question.responses {
            let uid = response.owner
            
            if uid != currentUID {
                // Updating the order value
                realtimeDBRef.child("Recent").child(uid).child(question.ID).child("order").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let order = snapshot.value as? Int
                    
                    if order != nil {
                        self.realtimeDBRef.child("Recent").child(uid).child(question.ID).updateChildValues(["order":order! - 1])
                        self.realtimeDBRef.child("Recent").child(uid).updateChildValues(["order":order! - 1])
                    }
                    else {
                        self.realtimeDBRef.child("Recent").child(uid).child(question.ID).updateChildValues(["order":500])
                        self.realtimeDBRef.child("Recent").child(uid).updateChildValues(["order":500])
                    }
                })
                
                // Updating the response number
                realtimeDBRef.child("Recent").child(uid).child(question.ID).child("responseNo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let responseNo = snapshot.value as? Int
                    
                    if responseNo != nil {
                        self.realtimeDBRef.child("Recent").child(uid).child(question.ID).updateChildValues(["responseNo":responseNo! + 1])
                    }
                    else {
                        self.realtimeDBRef.child("Recent").child(uid).child(question.ID).updateChildValues(["responseNo":1])
                    }
                })
            }
        }
    }
    
    func setResponseToZero(question: Question, currentUID: String) {
        self.realtimeDBRef.child("Recent").child(currentUID).child(question.ID).updateChildValues(["responseNo":0])
    }
    
    func updatePremiumQuestionResponse(question: Question, response: Response) {
        let responseArray = ["answer": response.answer, "date": response.date]
        
        realtimeDBRef.child("PremiumQuestionResponses").child(question.ID).child(response.owner).setValue(responseArray)
    }
    
    func updatePremiumQuestion(question: PremiumQuestion, index: Int) {
        let num = question.answers[index].respondsNum + 1
        realtimeDBRef.child("PremiumQuestionAnswers").child(question.ID).child(question.answers[index].id).updateChildValues(["responses": num])
    }
    
    func joinGroup(group: Group, username: String) {
        let userdetail = [username: true]
        
        realtimeDBRef.child("groupmembers").child(group.ID).updateChildValues(userdetail)
    }
    
    func removeMember(member : Account, group : Group) {
        realtimeDBRef.child("groupmembers").child(group.ID).child(member.username).setValue(nil)
    }
    
    func updateGroup(group : Group) {
        let groupArray = ["name": group.name, "owner": group.owner]
        
        realtimeDBRef.child("groups").child(group.ID).setValue(groupArray)
    }
    
    func loadTopic() {
        // Get the topics
        realtimeDBRef.child("Topics").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if !self.model.hasTopic(snapshot.key){
                print("Adding topic " + snapshot.key + " to model")
                
                let topic = Topic(name: snapshot.key)
                self.model.addTopic(topic)
                
                // Get the image from storage DB
                self.getTopicImage(snapshot.key, image: { (image) in
                    if image != nil {
                        self.model.addTopicImage(topic, image: image!)
                    }
                })
            }else{
                print("Topic \(snapshot.key) is in the model ")
            }
            
        })
    }
    
    func getProfileImage(imageName : String, image: (UIImage?) -> ()) {
        let imageRef = storageRef.child("images/profiles/" + imageName + ".jpg")
    
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                print("getProfileImage \(error?.localizedDescription)")
                image(UIImage(named: "p logo"))
            }
            else {
                image(UIImage(data: data!)!)
            }
        }
    }

    func getTopicImage(imageName : String, image: (UIImage?) -> ()) {
        let imageRef = storageRef.child("images/topics/" + imageName + ".png")
        
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                image(UIImage(named: "placeholder"))
            }
            else {
                image(UIImage(data: data!)!)
            }
        }
    }
    
    func getPremiumQuestionAnswerPhoto(imagenamed : String, image: (UIImage?) -> ()) {
        let imageRef = storageRef.child("images/PremiumQuestionAnswers/" + imagenamed)
        
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                image(UIImage(named: "placeholder"))
            }
            else {
                image(UIImage(data: data!)!)
            }
        }
    }
    
    func getGroupImage(name: String, image: (UIImage?) -> Void) {
        let imageRef = storageRef.child("images/groups/" + name + ".jpg")
        
        imageRef.dataWithMaxSize(5 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                image(UIImage(named: "placeholder"))
            }
            else {
                image(UIImage(data: data!))
            }
        }
    }
    
    func getQuestionAnswerPhoto(questionID: String, imagenamed : String, image: (UIImage?) -> ()) {
        let imageRef = storageRef.child("images/answers/" + questionID + "/" + imagenamed + ".jpg")
        
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                image(UIImage(named: "placeholder"))
            }
            else {
                image(UIImage(data: data!)!)
            }
        }
    }
    
    func getGroupQuestionAnswerPhoto(imagenamed : String, image: (UIImage?) -> ()) {
        let imageRef = storageRef.child("images/GroupQuestionAnswers/" + imagenamed)
        
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                image(UIImage(named: "placeholder"))
            }
            else {
                image(UIImage(data: data!)!)
            }
        }
    }
    
    func getPrivateQuestionAnswerPhoto(imagenamed : String, image: (UIImage?) -> ()) {
        let imageRef = storageRef.child("images/PrivateQuestionAnswers/" + imagenamed)
        
        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                image(UIImage(named: "placeholder"))
            }
            else {
                image(UIImage(data: data!)!)
            }
        }
    }
    
    func updateUIDForRecentPage(uid : String,phoneNum : String,email : String){
        //check recent by phone Number
        realtimeDBRef.child("Recent").child(phoneNum).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let recentContent = snapshot.value as? [String:AnyObject]{
                var recentList = [Recent]()
                for (key,value) in recentContent
                {
                    let responseNo = value["responseNo"] as? Int
                    if responseNo != nil {
                        let recent = Recent(id: key, order: value["order"] as! Int, responseNo: value["responseNo"] as! Int, type: value["type"] as! String)
                        recentList.append(recent)
                    }
                    else {
                        let order = value as? Int
                        self.realtimeDBRef.child("Recent").child(uid).updateChildValues(["order":order!])
                    }
                }
                
                self.realtimeDBRef.child("Recent").child(phoneNum).setValue(nil)
                
                for recent in recentList {
                    self.realtimeDBRef.child("Recent").child(uid).child(recent.id).updateChildValues(["order":recent.order, "responseNo":recent.responseNo, "type": recent.type])
                }
            }
            
        })
        //check recent by email
        realtimeDBRef.child("Recent").child(email.stringByReplacingOccurrencesOfString(".", withString: "")).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let recentContent = snapshot.value as? [String:AnyObject]{
                var recentList = [Recent]()
                for (key,value) in recentContent
                {
                    let recent = Recent(id: key, order: value["order"] as! Int, responseNo: value["responseNo"] as! Int, type: value["type"] as! String)
                    recentList.append(recent)
                }
                
                self.realtimeDBRef.child("Recent").child(email).setValue(nil)
                
                for recent in recentList {
                    self.realtimeDBRef.child("Recent").child(uid).child(recent.id).updateChildValues(["order":recent.order, "responseNo":recent.responseNo, "type": recent.type])
                }
            }
            
        })
    }
        
    // MARK: Test Methods
    func testUploadImage() {
        let image = UIImagePNGRepresentation(UIImage(named: "placeholder")!)
        
        let imageRef = storageRef.child("images/placeholder.png")
        
        let uploadTask = imageRef.putData(image!, metadata: nil) { metadata, error in
            if error != nil {
                
            }
            else {
                let downloadURL = metadata!.downloadURL
                self.downloadImage()
            }
        }
    }
    
    func downloadImage() {
        let imageRef = storageRef.child("images/placeholder.png")

        imageRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if error != nil {
                
            }
            else {
                let placeholderImage : UIImage! = UIImage(data: data!)
                print("image downloaded")
            }
        }
    }
}
