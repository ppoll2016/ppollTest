//
//  Model.swift
//  pPoll
//
//  Created by Nath on 8/10/16.
//  Copyright © 2016 syle. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class Model {
    var user : Account!
    var accounts = [Account]()
    var groups = [Group]()
    var questions = [Question]()
    var topics = [Topic]()
    var topicQuestions = [String:[Question]]()
    var managedContext : NSManagedObjectContext
    var questionMembers = [String:[Contact]]()
    
    var interestedTopics = [String]()
    var isSignUpDetailPage = false
    
    private struct Static {
        static var instance: Model?
    }
    
    class var sharedInstance: Model {
        if (Static.instance == nil) {
            Static.instance = Model()
        }
        
        return Static.instance!
    }
    
    init () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        loadQuestionToModel()
        
    }
    
    
    func addUserAccount(account: Account) {
        user = account
        accounts.append(account)
        if findAccountByUidCore(account.uid) == nil{
            addAccountToCore(account)
        }
       
    }
    
    func addAccount(account: Account) {
        accounts.append(account)
        addAccountToCore(account)
    }
    
    func findAccountByUid(uid: String) -> Account? {
        
        for account in accounts{
            if account.uid == uid {
                return account
            }
        }
        
        if let a = findAccountByUidCore(uid){
            let accountFromCore = Account(uid: a.uid, username: a.username, emailAddress: a.emailAddress, phoneNumber: a.phoneNumber, isPremium: false)
            if let profile = findProfileByUidCore(uid){
                let p = Profile(dateOfBirth: profile.dateOfBirth, gender: profile.gender, citizenship: profile.citizenship, nationality: profile.nationality, dateCreated: profile.dateCreated)
                p.photo = profile.profileImage
                accountFromCore.profile = p
                print("find Account By UId Core \(profile.profileImage)")
                
            }
            accounts.append(accountFromCore)
            return accountFromCore
        }
        
        return nil
    }
    func findPublicQuestionByUid (topic: String, uid: String) -> Question? {
        
        if let question = topicQuestions[topic] {
            for pq in question {
                if uid == pq.ID {
                    return pq
                }
            }
            
        }
        
        return nil
    }
    
    func addProfile(account: Account, profile: Profile) {
        account.profile = profile
        addProfileCore(account, profile: profile)
    }
    
    func addUserProfile(account: Account, profile: Profile) {
        user.profile = profile
        if findProfileByUidCore(account.uid) == nil{
            addProfileCore(account, profile: profile)

        }else
        {
            modifyProfileCore(account.uid, new: profile)
        }
    }
    
    func addUserProfileImage(image: UIImage) {
        user.profile.photo = image
        addProfileImageCore(user.uid, image: image)
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let questionPage = mainStoryBoard.instantiateViewControllerWithIdentifier("QuestionPage1") as! QuestionCreationViewController
        questionPage.image = image
    }
    
    func addProfileImage(profile: Profile, image: UIImage) {
        profile.photo = image
        
    }
    
    func removeUser(uid: String) {
        accounts.removeAtIndex(accounts.indexOf({ $0.uid == uid })!)
    }
    
    func updateAccount(account: Account) {
        accounts[accounts.indexOf(account)!] = account
    }
    
    func removeProfile(uid: String) {
        accounts[accounts.indexOf({ $0.uid == uid })!].profile = nil
    }
    
    func updateProfile(uid: String, profile: Profile) {
        accounts[accounts.indexOf({ $0.uid == uid })!].profile = profile
    }
    
    func addInterestedTopic(topic: String) {
        interestedTopics.append(topic)
    }
    
    func updateInterestedTopicArray(topics:[String]){
        self.interestedTopics = topics
        
    }
    
    func addTopic(topic: Topic) {
        topics.append(topic)
        addTopicCore(topic)
    }
    
    func addTopicImage(topic: Topic, image: UIImage) {
        topic.photo = image
        addTopicImageCore(topic, image: image)
    }
    
    func hasTopic(name: String) -> Bool{
        for topic in topics{
            if name == topic.name{
                return true
            }
        }
        return false
    }
    
    func removeTopic(name: String) {
        topics.removeAtIndex(topics.indexOf({ $0.name == name })!)
    }
    
    func addQuestion(question: Question) {
        if !questions.contains(question) {
            questions.append(question)
        }
    }
    
    func addGroupQuestion(question: GroupQuestion) {
        addQuestion(question)
        
        let group = groups[groups.indexOf({ $0.ID == question.group.ID })!]
        
        if !group.questions.contains(question) {
            group.questions.append(question)
        }
    }
    
    func addTopicToQuestion(question: PremiumQuestion, topic: Topic) {
        question.topics.append(topic)
    }
    
    func addAnswerToQuestion(question: Question, answer: Answer) {
        if !question.answers.contains(answer) {
            question.answers.append(answer)
        }
    }
    
    func addResponseToQuestion(question: Question, response: Response) {
        if !question.responses.contains(response) {
            question.responses.append(response)
        }
    }
    
    func removeResponseFromQuestion(question: Question, owner: String) {
        question.responses.removeAtIndex(question.responses.indexOf({ $0.owner == owner })!)
    }
    
    func updateResponseFromUser(question: Question, response: Response) {
        question.responses[question.responses.indexOf(response)!] = response
    }
    
    func removeQuestion(questionID: String) {
        questions.removeAtIndex(questions.indexOf({ $0.ID == questionID })!)
    }
    
    func updateQuestion(question: Question) -> Question {
        let questionModel = questions[questions.indexOf(question)!]
        
        questionModel.content = question.content
        questionModel.isPublic = question.isPublic
        
        return questionModel
    }
    
    func removeGroup(groupID: String) {
        let group = groups[groups.indexOf({ $0.ID == groupID })!]
        
        for member in group.members {
            member.groups.removeAtIndex(member.groups.indexOf(group)!)
        }
        
        groups.removeAtIndex(groups.indexOf(group)!)
    }
    
    func addGroupMember(uid: String, group: Group) {
        let account = accounts[accounts.indexOf({ $0.uid == uid })!]
        let group = groups[groups.indexOf({ $0.ID == group.ID })!]
        
        if !group.members.contains(account) {
            account.groups.append(group)
            group.members.append(account)
        }
    }
    
    func assignContacts(contacts: [Account]) {
        for contact in contacts {
            user.contacts.append(contact)
        }
    }
    
    func removeGroupMember(uid: String, group: Group) {
        let account = accounts[accounts.indexOf({ $0.uid == uid })!]
        let group = groups[groups.indexOf({ $0.ID == group.ID })!]
        
        account.groups.removeAtIndex(account.groups.indexOf(group)!)
        group.members.removeAtIndex(group.members.indexOf(account)!)
    }
    
    func addGroup(group: Group) {
        groups.append(group)
        addGroupCore(group)
    }
    
    func updateGroup(group: Group) -> Group {
        let modelGroup = groups[groups.indexOf({ $0.ID == group.ID })!]
        modelGroup.name = group.name
        
        return modelGroup
    }
    
    func addContact(account: Account) {
        user.contacts.append(account)
    }
    
    func removeContact(uid: String) {
        user.contacts.removeAtIndex(user.contacts.indexOf({ $0.uid == uid })!)
    }
    
    // MARK: Filter Methods
    
    func filterAvailableGroups(searchString : String, groups : [Group]) -> [Group] {
        return groups.filter({ (group) in filterGroups(searchString, group: group)})
    }
    
    func filterGroups(searchString : String, group : Group) -> Bool {
        if (NSString(string: group.name).rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
            return true
        }
        
        return false
    }
    
    func filterAvailableAccounts(searchString : String, accounts : [Account]) -> [Account] {
        return accounts.filter({ (account) in filterAccounts(searchString, account: account)})
    }
    
    func filterAccounts(searchString : String, account : Account) -> Bool {
        if (NSString(string: account.username).rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
            return true
        }
        else if (NSString(string: account.emailAddress).rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
            return true
        }
        
        return false
    }
    
    func filterAvailableTopics(searchString : String, topics : [Topic]) -> [Topic] {
        return topics.filter({ (topic) in filterTopics(searchString, topic: topic)})
    }
    
    func filterTopics(searchString : String, topic : Topic) -> Bool {
        if (NSString(string: topic.name).rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
            return true
        }
        
        return false
    }
    
    func findQuestionByUid (uid:String) -> Question? {
        for q in questions {
            if uid == q.ID{
                return q
            }
        }
        return nil
    }
    
    func findGroupById (uid :String) -> Group? {
        for g in groups{
            if uid == g.ID{
                return g
            }
        }
        if let group = findGroupByUidCore(uid){
            let groupFromCore = Group(ID: group.id, name: group.name, owner: group.owner)
            addGroup(groupFromCore)
            return groupFromCore
        }
        
        return nil
    }
    
    //MARK: Core data method
    func addAccountToCore(a: Account){
        
        guard let accountEntity = NSEntityDescription.entityForName("AccountCore", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let account = AccountCore(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        
        account.uid = a.uid
        account.isPremium = a.isPremium
        account.emailAddress = a.emailAddress
        account.phoneNumber = a.phoneNumber
        account.username = a.username
     
        try! managedContext.save()
    }
    
    func addProfileCore(account: Account, profile: Profile) {
      
        guard let accountEntity = NSEntityDescription.entityForName("ProfileCore", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let profileCore = ProfileCore(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        
        profileCore.uid = account.uid
        profileCore.citizenship = profile.citizenship
        profileCore.dateCreated = profile.dateCreated
        profileCore.dateOfBirth = profile.dateOfBirth
        profileCore.gender = profile.gender
        profileCore.nationality = profile.nationality
        profileCore.profileImage = profile.photo
        
        try! managedContext.save()
    }
    
    func modifyProfileCore(uid:String, new:Profile){
        if let profile = findProfileByUidCore(uid){
            profile.citizenship = new.citizenship
            profile.dateCreated = new.dateCreated
            profile.dateOfBirth = new.dateOfBirth
            profile.gender = new.gender
            profile.nationality = new.nationality
            
        }
        try! managedContext.save()
        
    }
    
    func addProfileImageCore(uid:String,image: UIImage){
        if let profile = findProfileByUidCore(uid){
            print("addProfileImage Core = \(image)")
            profile.profileImage = image
        }
        try! managedContext.save()
    }
    
    func addGroupCore(group: Group) {
        guard let accountEntity = NSEntityDescription.entityForName("GroupCore", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let groupCore = GroupCore(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        
        groupCore.id = group.ID
        groupCore.name = group.name
        groupCore.owner = group.owner
        
        try! managedContext.save()
    }
    
    func addQuestionCore(q: Question) {
        guard let accountEntity = NSEntityDescription.entityForName("QuestionCore", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let questionCore = QuestionCore(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        
        questionCore.id = q.ID
        questionCore.content = q.content
        questionCore.date = q.date
        questionCore.owner = q.owner
        questionCore.isPublic = q.isPublic
        questionCore.responseNo = q.responseNo
        questionCore.members = q.members
        try! managedContext.save()
    }
    
    func addGroupQuestionCore(q: GroupQuestion) {
        guard let accountEntity = NSEntityDescription.entityForName("GroupQuestionCore", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let groupQuestionCore = GroupQuestionCore(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        
        groupQuestionCore.id = q.ID
        groupQuestionCore.content = q.content
        groupQuestionCore.date = q.date
        groupQuestionCore.owner = q.owner
        groupQuestionCore.isPublic = q.isPublic
        groupQuestionCore.responseNo = q.responseNo
        groupQuestionCore.groupid = q.group.ID
        
        try! managedContext.save()
    }
    
    func addOrderCore(id: String,type:String) {
        guard let accountEntity = NSEntityDescription.entityForName("Order", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let order = Order(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        order.uid = id
        order.questionType = type
        try! managedContext.save()
    }
    
    
    func findAccountByUidCore(uid:String) -> AccountCore?{
        let fetchReuqest = NSFetchRequest(entityName: "AccountCore")
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchReuqest.predicate = predicate
        do {
            if let results = try managedContext.executeFetchRequest(fetchReuqest) as? [AccountCore]{
                for result in results {
                    return result
                }
            }
            
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func findGroupByUidCore(uid:String) -> GroupCore?{
        let fetchReuqest = NSFetchRequest(entityName: "GroupCore")
        let predicate = NSPredicate(format: "id == %@", uid)
        fetchReuqest.predicate = predicate
        do {
            if let results = try managedContext.executeFetchRequest(fetchReuqest) as? [GroupCore]{
                for result in results {
                    return result
                }
            }
            
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func findProfileByUidCore(uid:String) -> ProfileCore?{
        let fetchReuqest = NSFetchRequest(entityName: "ProfileCore")
        let predicate = NSPredicate(format: "uid == %@", uid)
        fetchReuqest.predicate = predicate
        do {
            if let results = try managedContext.executeFetchRequest(fetchReuqest) as? [ProfileCore]{
                for result in results {
                    return result
                }
            }
            
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func findGroupQuestionByUidCore(uid:String) -> GroupQuestionCore?{
        let fetchReuqest = NSFetchRequest(entityName: "GroupQuestionCore")
        let predicate = NSPredicate(format: "id == %@", uid)
        fetchReuqest.predicate = predicate
        do {
            if let results = try managedContext.executeFetchRequest(fetchReuqest) as? [GroupQuestionCore]{
                for result in results {
                    return result
                }
            }
            
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func findQuestionByUidCore(uid:String) -> QuestionCore?{
        let fetchReuqest = NSFetchRequest(entityName: "QuestionCore")
        let predicate = NSPredicate(format: "id == %@", uid)
        fetchReuqest.predicate = predicate
        do {
            if let results = try managedContext.executeFetchRequest(fetchReuqest) as? [QuestionCore]{
                for result in results {
                    return result
                }
            }
            
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func getAllQuestionCore() -> [QuestionCore]?{
        let fetchRequest = NSFetchRequest(entityName: "QuestionCore")
        
        do {
            if let results = try managedContext.executeFetchRequest(fetchRequest) as? [QuestionCore]{
                return results
            }
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func getAllGroupQuestionCore() -> [GroupQuestionCore]?{
        let fetchRequest = NSFetchRequest(entityName: "GroupQuestionCore")
        
        do {
            if let results = try managedContext.executeFetchRequest(fetchRequest) as? [GroupQuestionCore]{
                return results
            }
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func getAllOrderCore() -> [Order]?{
        let fetchRequest = NSFetchRequest(entityName: "Order")
        
        do {
            if let results = try managedContext.executeFetchRequest(fetchRequest) as? [Order]{
                return results
            }
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func deleteQuestionCore(uid: String){
        if let q = findQuestionByUidCore(uid){
            managedContext.deleteObject(q)
        }
        if let q = findGroupQuestionByUidCore(uid){
            managedContext.deleteObject(q)
        }
        try! managedContext.save()

    }
    
    func deleteCurrentUserQuestionsCore(){
        if let question = getAllQuestionCore(){
            for q in question{
                managedContext.deleteObject(q)
            }
        }
        
        if let question = getAllGroupQuestionCore(){
            for q in question{
                managedContext.deleteObject(q)
            }
        }
        
        if let question = getAllOrderCore(){
            for q in question{
                managedContext.deleteObject(q)
            }
        }
        try! managedContext.save()

    }
    
    //MARK: Topic Coredata
    
    func addTopicCore(topic:Topic) {
        guard let accountEntity = NSEntityDescription.entityForName("TopicCore", inManagedObjectContext:managedContext) else {
            fatalError("fatal Error couldnt find entity description")
        }
        
        let topicCore = TopicCore(entity: accountEntity, insertIntoManagedObjectContext: managedContext)
        
        topicCore.name = topic.name
        topicCore.topicImage = UIImage(named: "placeholder")!
        try! managedContext.save()
    }
    
    func addTopicImageCore(topic: Topic, image: UIImage) {
        if let topic = findTopicByNameCore(topic.name){
            print("addTopicImage Core = \(image)")
            topic.topicImage = image
        }
        try! managedContext.save()
    }
    
    func findTopicByNameCore(name:String) -> TopicCore?{
        let fetchReuqest = NSFetchRequest(entityName: "TopicCore")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchReuqest.predicate = predicate
        do {
            if let results = try managedContext.executeFetchRequest(fetchReuqest) as? [TopicCore]{
                for result in results {
                    return result
                }
            }
            
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    func getAllTopicCore() -> [TopicCore]?{
        let fetchRequest = NSFetchRequest(entityName: "TopicCore")
        
        do {
            if let results = try managedContext.executeFetchRequest(fetchRequest) as? [TopicCore]{
                return results
            }
        }catch{
            print("fetch error")
        }
        return nil
    }
    
    //call this when quit the app
    func saveQuestionToModel(){
        //delete all record in coredata
        deleteCurrentUserQuestionsCore()
        
        for q in questions {
            
            if let groupquestion = q as? GroupQuestion {
                addGroupQuestionCore(groupquestion)
                addOrderCore(q.ID,type: "G")
            }else{
                addQuestionCore(q)
                addOrderCore(q.ID,type: "P")
                
            }
        }
        
    }
    
    //Call this every time start the app
    func loadQuestionToModel() {
        
        if let order = getAllOrderCore(){
            for i in order{
                if i.questionType == "G"{
                    if let new = findGroupQuestionByUidCore(i.uid){
                        if let group = findGroupByUidCore(i.uid){
                            let g = Group(ID: group.id, name: group.name, owner: group.owner)
                            let gq = GroupQuestion(ID: new.id, content: new.content, date: new.date, owner: new.owner, group: g)
                            gq.responseNo = new.responseNo as Int
                            questions.append(gq)
                            addGroup(g)
                        }
                    }
                }else{
                    if let new = findQuestionByUidCore(i.uid){
                        let q = Question(ID: new.id, content: new.content, date: new.date, owner: new.owner)
                        q.responseNo = new.responseNo as Int
                        q.members = new.members as String
                        questions.append(q)
                        
                    }
                    
                }
            }
        }
        print("ques from model coredata \(questions.count)")
        
        if let topicCore = getAllTopicCore(){
            for t in topicCore{
                let topic = Topic(name: t.name)
                topic.photo = t.topicImage
                topics.append(topic)
            }
        }
        
    }
    
}





extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = UIImagePNGRepresentation(self)!
        let data2: NSData = UIImagePNGRepresentation(image)!
        return data1.isEqual(data2)
    }
    
}









