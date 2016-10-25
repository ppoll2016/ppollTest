//
//  PublicQController.swift
//  pPoll
//
//  Created by syle on 9/09/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase
import Social
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class PublicQController: UIViewController {
    lazy var ref = FIRDatabase.database().reference()
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    var userId: String!
    //TRACK the newIndex order from firebase
    var newIndex: Int!
    var LoadingViewController: LoadingScreenViewController!
    var orderLowestOrder = 10000
    
    // firebase database reference
    var accountsRef: FIRDatabaseReference!
    var groupQuestionRef: FIRDatabaseReference!
    var questionRef: FIRDatabaseReference!
    //  var answersRef: FIRDatabaseReference!
    var recentRef: FIRDatabaseReference!
    var questionMemberRef: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    var groupRef: FIRDatabaseReference!
    
    //questions that display the tableview
    var questions: [Question] = []
    var questionsFirebase: [Question] = []
    var filterQuestions = [Question]()
    var filterUID = [String]()
    
    var showSearchResults  = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    var rightBarButtons : [UIBarButtonItem]!
    var leftBarButtons : [UIBarButtonItem]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("questiion count + \(questions.count)")
        searchBar.delegate = self
        LoadingViewController = storyboard?.instantiateViewControllerWithIdentifier("loadingScreen") as! LoadingScreenViewController
        LoadingViewController.delegate = self
        
        self.navigationItem.leftBarButtonItem = nil
        userId = FIRAuth.auth()?.currentUser?.uid
        //userId = "xYauN7RhNZMO64mGFtZcnYKFRpo2"
        print("Current UID: " + userId)
        
        accountsRef = ref.child("Accounts")
        groupQuestionRef = ref.child("GroupQuestions")
        recentRef = ref.child("Recent").child(userId)
        questionRef = ref.child("PrivateQuestions")
        questionMemberRef = ref.child("QuestionMembers")
        profileRef = ref.child("Profiles")
        groupRef = ref.child("Groups")
        
        tableView.rowHeight = 65.0
        //        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65.0
        automaticallyAdjustsScrollViewInsets = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear !!!!")
        recentRef.removeAllObservers()
        questions.removeAll()
        questionsFirebase.removeAll()
        if (model.questions.count != 0){
            questions = model.questions
            questionsFirebase = model.questions
        }
        tableView.reloadData()
        newIndex = 0
        fetchQuestionsINGCD()
        addProfileImageToNavigationBar()
    }
    
    func addProfileImageToNavigationBar(){
        let imageHolder: UIImage = UIImage(named: "p logo")!
        var image = imageHolder
        // let image = model.user.profile.photo
        if let photo: UIImage = model.user?.profile?.photo {
            image = photo
        }
        
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 40, 40)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true
        button.layer.cornerRadius = CGRectGetHeight(button.bounds)/2.0
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(self.rightNavBarItemAction), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem?.customView = button
    }
    
    func rightNavBarItemAction() {
        performSegueWithIdentifier("GoToProfileFromAnswersPage", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateTabItemBadge()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("Disappearing>>>")
        searchBar.endEditing(true)
        LoadingOverlay.shared.hideOverlayView()
        self.newIndex = 0
        // maintain model
        model.questions.removeAll()
        questions = questions.filter{$0.date != " "}
        model.questions = questions
        
        // remove observer
        groupQuestionRef.removeAllObservers()
    }
    
    
    //MARK: handle the tab bar item badge
    func updateTabItemBadge(){
        var badgeNumber = 0
        for q in questions {
            badgeNumber = badgeNumber + q.responseNo
        }
        if badgeNumber != 0 {
            
            // tabBarController?.tabBar.items?.last?.badgeValue  = "\(badgeNumber)"
            let values = [0,0,badgeNumber]
            tabBarController?.setBadges(values)
        }else
        {
            //            tabBarController?.tabBar.items?.last?.badgeValue  = nil
            let values = [0,0,0]
            tabBarController?.setBadges(values)
        }
    }
    
    func fetchQuestionsINGCD() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue){
            let group = dispatch_group_create()
            dispatch_group_async(group, queue) {
                self.fetchQuestions()
            }
            dispatch_group_notify(group, queue){
                dispatch_async(dispatch_get_main_queue()){
                }
            }
        }
    }
    
    func checkRemoveQuestion(){
        print("checkRemoveQuestion")
        for q in questions{
            print("ID: \(q.ID) , Content: \(q.content)")
            
            ref.child("RemovedQuestions").child(q.ID).observeSingleEventOfType(.Value, withBlock: {
                (snapshot) in
                if (snapshot.key as? String) != nil {
                    print("1234456789976543")
                }
                
            })
        }
    }
    
    func fetchQuestions() {
        checkRemoveQuestion()
        recentRef.queryOrderedByChild("order").observeEventType(.ChildAdded, withBlock: {
            (snapshot) in
//            print("childAdded")
//            print("Current Index \(self.newIndex)")
//            print(snapshot)
            if let dic = snapshot.value as? [String:AnyObject]{
                guard let questionType = dic["type"] as? String else {
                    return
                }
                guard let responseNo = dic["responseNo"] as? Int else {
                    return
                }
                
                guard let order = dic["order"] as? Int else {
                    return
                }
                
                if order < self.orderLowestOrder {
                    self.orderLowestOrder = order
                    self.newIndex = 0
                }
                
                switch questionType {
                case "GroupQuestions":
                    
                    self.fetchGroupQuestion(snapshot.key,responseNo: responseNo, newIndex: self.newIndex, completion: { (error) in
                        if error != nil {
                            // handle error
                        } else {
                            print("Group question Fetch completed")
                            //replace the old order with firebase order
                            self.questions.removeAll()
                            
                            self.questions = self.questionsFirebase.filter{$0.date != " "}
                            
                            self.tableView.reloadData()
                            self.updateTabItemBadge()
                            LoadingOverlay.shared.hideOverlayView()
                            
                        }
                    })
                    self.newIndex = self.newIndex + 1
                    break
                    
                case "Questions":
                    
                    self.fetchNormalQuestion(snapshot.key,responseNo: responseNo, newIndex: self.newIndex, completion: { (error) in
                        if error != nil {
                            // handle error
                        } else {
                            print("Privite question Fetch completed")
                            //replace the old order with firebase order
                            self.questions.removeAll()
                            self.questions = self.questionsFirebase.filter{$0.date != " "}
                            self.tableView.reloadData()
                            self.updateTabItemBadge()
                            LoadingOverlay.shared.hideOverlayView()
                        }
                    })
                    self.newIndex = self.newIndex + 1
                    break
                    
                default: break
                }// end of switch
            }
        })
        
        recentRef.observeEventType(.ChildChanged, withBlock: {
            (snapshot) in
            print("childChange!")
            print(snapshot)
            if let dic = snapshot.value as? [String:AnyObject]{
                guard let responseNo = dic["responseNo"] as? Int else {
                    return
                }
                
                if let index = self.questions.indexOf({$0.ID == snapshot.key}) {
                    let newQuestion = self.questions[index]
                    newQuestion.responseNo = responseNo
                    
                    
                    self.questions.removeAtIndex(self.questions.indexOf(newQuestion)!)
                    self.questions.insert(newQuestion, atIndex: 0)
                    self.tableView.reloadData()
                    self.updateTabItemBadge()
                    
                }
                
            }
        })
        
        
    }
    
    func fetchNormalQuestion(uid: String,responseNo:Int, newIndex:Int, completion: (ErrorType?)-> ()){
        
        // check if question in the model, otherwise fetch from firebase
        if model.findQuestionByUid(uid) != nil {
            
            // swap questions to the new order
            var oldIndex:Int!
            
            if questionsFirebase.count == 0{return}
            
            for i in 0 ... questionsFirebase.count - 1 {
                if questionsFirebase[i].ID == uid {
                    oldIndex = i
                    break
                }
            }
            
            if oldIndex == nil {return}
            
            self.questionsFirebase.moveItem(fromIndex: oldIndex, toIndex: newIndex)
            self.questionsFirebase[newIndex].responseNo = responseNo
            self.questions = self.questionsFirebase
            self.tableView.reloadData()
        }else{
            LoadingOverlay.shared.showOverlay(self.view)
            
            //place holer question
            let placeHolerQ = Question(ID: String(newIndex), content: "", date: " ", owner: "")
            placeHolerQ.responseNo = 0
            self.questionsFirebase.insert(placeHolerQ, atIndex: newIndex)
            questionRef.child(uid).observeSingleEventOfType(.Value, withBlock: {
                (snapshot) in
                if let dic = snapshot.value as? [String: AnyObject] {
                    let newQuestion = Question(ID: uid, snapShot: dic)
                    newQuestion.responseNo = responseNo
                    // grab question members
                    self.questionMemberRef.child(uid).queryLimitedToFirst(3).observeSingleEventOfType(.Value, withBlock: {
                        (snapshot) in
                        print("question member")
                        print(snapshot)
                        if let questionMemberDic = snapshot.value as? [String : String]{
                            var members: String = ""
                            for (_,m) in questionMemberDic {
                                members = members + "\(m), "
                            }
                            var membersWithoutComma = String(members.characters.dropLast())
                            membersWithoutComma = String(membersWithoutComma.characters.dropLast())
                            newQuestion.members = membersWithoutComma
                            self.tableView.reloadData()
                        }
                    })
                    
                    //remove the place holder question and add real question from firebase
                    var placeHolderIndex:Int!
                    
                    if self.questionsFirebase.count == 0{return}
                    
                    for i in 0 ... self.questionsFirebase.count - 1 {
                        if self.questionsFirebase[i].ID == String(newIndex) {
                            placeHolderIndex = i
                            break
                        }
                    }
                    
                    if placeHolderIndex == nil {return}
                    
                    self.questionsFirebase.removeAtIndex(placeHolderIndex)
                    self.questionsFirebase.insert(newQuestion, atIndex: newIndex)
                    completion(nil)
                    print("new Question owner \(newQuestion.owner)")
                    // add account to model if it is not in model
                    if self.model.findAccountByUid(newQuestion.owner) == nil {
                        self.accountsRef.child(newQuestion.owner).observeSingleEventOfType(.Value, withBlock: { (snapshotAccount) in
                            let newAcc = Account(uid: newQuestion.owner, snapshot: snapshotAccount.value as! [String : AnyObject])
                            self.model.addAccount(newAcc)
                            //add profile to account
                            self.profileRef.child(newAcc.uid).observeSingleEventOfType(.Value, withBlock: {
                                (snapshotProfile) in
                                if let p = snapshotProfile.value as? [String : AnyObject]{
                                    let profile = Profile(snapshot: p)
                                    self.model.addProfile(newAcc, profile: profile)
                                    // get profile image
                                    self.firebaseModel.getProfileImage(newAcc.uid, image: { (image) in
                                        profile.photo = image!
                                        print(image!)
                                        print(newAcc.uid)
                                        print("retrieve from normal question ===\(image)")
                                        self.model.addProfileImageCore(newAcc.uid, image: image!)
                                        self.tableView.reloadData()
                                    })
                                }
                                
                                
                            })
                            
                        })
                    }
                }
            })
        }// end of if
        
        
        
    }
    
    func fetchGroupQuestion(uid: String,responseNo:Int, newIndex:Int, completion: (ErrorType?)-> ()){
        if model.findQuestionByUid(uid) != nil {
            // swap questions to the new order
            var oldIndex:Int!
            
            if questionsFirebase.count == 0{return}
            
            for i in 0 ... questionsFirebase.count - 1 {
                if questionsFirebase[i].ID == uid {
                    oldIndex = i
                    break
                }
            }
            
            if oldIndex == nil {return}
            
            self.questionsFirebase.moveItem(fromIndex: oldIndex, toIndex: newIndex)
            self.questionsFirebase[newIndex].responseNo = responseNo
            self.questions = self.questionsFirebase
            
            self.tableView.reloadData()
        }else{
            LoadingOverlay.shared.showOverlay(self.view)
            
            //place holer question
            let placeHolerQ = Question(ID: String(newIndex), content: "", date: " ", owner: "")
            placeHolerQ.responseNo = 0
            self.questionsFirebase.insert(placeHolerQ, atIndex: newIndex)
            
            groupQuestionRef.child(uid).observeSingleEventOfType(.Value, withBlock: {
                (snap) in
                if let dec = snap.value as? [String:AnyObject] {
                    //grab groupId to construct group
                    if let groupId = dec["groupID"] as? String {
                        var group: Group!
                        //check if group exist
                        if let group = self.model.findGroupById(groupId) {
                            //construct groupquestion and update to model
                            let newGroupQuestion = GroupQuestion(ID: uid, snapShot: dec, group: group)
                            newGroupQuestion.responseNo = responseNo
                            
                            if self.questionsFirebase.count == 0{return}
                            
                            //remove the place holder question and add real question from firebase
                            var placeHolderIndex:Int!
                            for i in 0 ... self.questionsFirebase.count - 1 {
                                if self.questionsFirebase[i].ID == String(newIndex) {
                                    placeHolderIndex = i
                                    break
                                }
                            }
                            
                            if placeHolderIndex == nil {return}
                            
                            self.questionsFirebase.removeAtIndex(placeHolderIndex)
                            self.questionsFirebase.insert(newGroupQuestion, atIndex: newIndex)
                            
                        }else{
                            // grab group info from firebase
                            self.groupRef.child(groupId).observeSingleEventOfType(.Value, withBlock: {
                                (groupSnap) in
                                if let groupDic = groupSnap.value as? [String:AnyObject] {
                                    group = Group(ID: groupId, snapShot: groupDic)
                                    
                                    //construct groupquestion and update to model
                                    let newGroupQuestion = GroupQuestion(ID: uid, snapShot: dec, group: group)
                                    newGroupQuestion.responseNo = responseNo
                                    self.model.addGroup(group)
                                    
                                    if self.questionsFirebase.count == 0 {return}
                                    
                                    //remove the place holder question and add real question from firebase
                                    var placeHolderIndex:Int!
                                    for i in 0 ... self.questionsFirebase.count - 1 {
                                        if self.questionsFirebase[i].ID == String(newIndex) {
                                            placeHolderIndex = i
                                            break
                                        }
                                    }
                                    if placeHolderIndex == nil{return}
                                    
                                    self.questionsFirebase.removeAtIndex(placeHolderIndex)
                                    self.questionsFirebase.insert(newGroupQuestion, atIndex: newIndex)
                                    completion(nil)
                                    
                                    // add account to model if it is not in model
                                    if self.model.findAccountByUid(newGroupQuestion.owner) == nil {
                                        self.accountsRef.child(newGroupQuestion.owner).observeSingleEventOfType(.Value, withBlock: { (snapshotAccount) in
                                            let newAcc = Account(uid: newGroupQuestion.owner, snapshot: snapshotAccount.value as! [String : AnyObject])
                                            self.model.addAccount(newAcc)
                                            //add profile to account
                                            self.profileRef.child(newAcc.uid).observeSingleEventOfType(.Value, withBlock: {
                                                (snapshotProfile) in
                                                if let p = snapshotProfile.value as? [String : AnyObject]{
                                                    let profile = Profile(snapshot: p)
                                                    self.model.addProfile(newAcc, profile: profile)
                                                    // get profile image
                                                    self.firebaseModel.getProfileImage(newAcc.uid, image: { (image) in
                                                        profile.photo = image!
                                                        print(image!)
                                                        print(newAcc.uid)
                                                        print("retrieve from normal question ===\(image)")
                                                        self.model.addProfileImageCore(newAcc.uid, image: image!)
                                                        self.tableView.reloadData()
                                                    })
                                                }
                                                
                                            })
                                            
                                        })
                                    }
                                    
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    }
                    
                    
                }
                
            })
        }// end of if
    }
    
    @IBAction func unwindToPremium (segue : UIStoryboardSegue) {
        tableView.reloadData()
    }
    
}

extension PublicQController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResults {
            return filterQuestions.count
        }
        else {
            return questions.count
        }
        // return premiumQuestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("PublicQ", forIndexPath: indexPath)
        
        if let Cell = cell as? PublicQCell{
            let pQ : Question
            
            if showSearchResults {
                pQ = filterQuestions[indexPath.row]
            }
            else {
                pQ = questions[indexPath.row]
            }
            
            
            //  let pQ = premiumQuestions[indexPath.row]
            //  let pA = pQ.answers
            
            Cell.questionName.text = pQ.content
            Cell.questionDate.text = pQ.date
            
            let responseNo = pQ.responseNo
            if pQ is GroupQuestion {
                Cell.userName.text = (pQ as! GroupQuestion).group.name
                Cell.setUpNewResponsd(responseNo)
                
            }else{
                // display the users that participate the question
                
                Cell.userName.text = pQ.members
                Cell.setUpNewResponsd(pQ.responseNo)
                
            }
            
            let owner = pQ.owner
            if let photo = model.findAccountByUid(owner)?.profile?.photo {
                Cell.ownerImage.image = photo
                
            }
            
            //            if let profile = model.findProfileByUidCore(owner){
            //                Cell.ownerImage.image = profile.profileImage
            //            }else if let photo = model.findAccountByUid(owner)?.profile?.photo {
            //   Cell.ownerImage.image = photo
            //
            //  }
            
            
        }
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.endEditing(true)
        
        recentRef.child(questions[indexPath.row].ID).child("responseNo").setValue(0)
        //self.performSegueWithIdentifier("premiumShowAnswer", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "premiumShowAnswer" {
            let destinationController = segue.destinationViewController as! ResultViewController
            
            if showSearchResults {
                destinationController.question = filterQuestions[(tableView.indexPathForSelectedRow?.row)!]
                print(filterQuestions.count)
                print("showSearchResults")
            }
            else
            {
                destinationController.question = questions[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
}

extension PublicQController: UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "Share") {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            self.ShowShareSheet()
            
        }
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") {
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            print("delete")
            print(indexPath)
            let uid = self.questions[indexPath.row].ID
            //delete from coredata
            self.model.deleteQuestionCore(uid)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.recentRef.child(uid).removeValue()
            //   self.model.questions.removeAtIndex(indexPath.row)
            self.questions.removeAtIndex(indexPath.row)
            self.questionsFirebase.removeAtIndex(indexPath.row)
            tableView.endUpdates()
            
            self.newIndex = 0
            
            self.updateTabItemBadge()
        }
        
        shareAction.backgroundColor = UIColor.blueColor()
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [shareAction, deleteAction]
    }
    
    func shareToFaceBook(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            self.presentViewController(fbShare, animated: true, completion: nil)
        } else {
            ShowPopUpDailog("Accounts", message: "Please login to a Facebook Account to share")
        }
    }
    
    func ShowShareSheet (){
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let shareAction = UIAlertAction(title: "Share To FaceBook", style: .Default) { (Action) in
            self.shareToFaceBook()
            
        }
        
        let inviteAction = UIAlertAction(title: "Invite from FaceBook", style: .Default) { (Action) in
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: "https://www.mydomain.com/myapplink")!
            //optionally set previewImageURL
            content.appInvitePreviewImageURL = NSURL(string: "https://www.mydomain.com/my_invite_image.jpg")!
            // Present the dialog. Assumes self is a view controller
            // which implements the protocol `FBSDKAppInviteDialogDelegate`.
            FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
            
        }
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        
        myAlert.addAction(shareAction)
        myAlert.addAction(cancelActionButton)
        myAlert.addAction(inviteAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func ShowPopUpDailog( title:String, message:String){
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "ok", style: .Default) { (Action) in
            // self.dismissViewControllerAnimated(true, completion: nil)
            print("ok clicked")
        }
        
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
}

extension PublicQController: UISearchBarDelegate{
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterQuestions = questions.filter{$0.content.lowercaseString.rangeOfString(searchText.lowercaseString) != nil}
        
        if searchText != "" {
            showSearchResults = true
            tableView.reloadData()
        }
        else {
            showSearchResults = false
            tableView.reloadData()
        }
        
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        showSearchResults = true
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
}

extension Array {
    mutating func moveItem(fromIndex oldIndex: Index, toIndex newIndex: Index) {
        insert(removeAtIndex(oldIndex), atIndex: newIndex)
    }
}

extension PublicQController: FBSDKAppInviteDialogDelegate {
    //MARK: FBSDKAppInviteDialogDelegate
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invitation made")
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("error made")
    }
}

extension PublicQController: LoadingViewDelegate{
    func fetchCurrentUserImageComplete() {
        tableView.reloadData()
    }
}



