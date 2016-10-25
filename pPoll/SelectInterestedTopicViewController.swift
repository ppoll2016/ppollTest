//
//  SelectTopicViewController.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase

class SelectInterestedTopicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    
    lazy var ref = FIRDatabase.database().reference()
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    var topics = [Topic]()
    var filteredTopics = [Topic]()
    var seletedTopics = [Bool]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase References
    var accountsRef: FIRDatabaseReference!
    var accountGroupRef: FIRDatabaseReference!
    
    var showSearchResults  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        topics = model.topics
        let interestedTopic = model.interestedTopics;
        for topic in topics {
            self.seletedTopics.append(interestedTopic.contains(topic.name))
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTopics = topics.filter({ (topic : Topic) -> Bool in
            topic.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResults {
            return filteredTopics.count
        }
        else {
            return topics.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if showSearchResults {
            let index = topics.indexOf({ $0.name == filteredTopics[indexPath.row].name })
            
            if seletedTopics[index!] {
                seletedTopics[index!] = false
            }
            else {
                seletedTopics[index!] = true
            }
        }
        else {
            if seletedTopics[indexPath.row] {
                seletedTopics[indexPath.row] = false
            }
            else {
                seletedTopics[indexPath.row] = true
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Topic Cell", forIndexPath: indexPath) as! CircularTableViewCell
        
        // Configure the cell
        let topic : Topic
        
        if showSearchResults {
            topic = filteredTopics[indexPath.row]
        }
        else {
            topic = topics[indexPath.row]
        }
        
        cell.circularImage.image = topic.photo
        cell.circularImage.layer.cornerRadius = cell.circularImage.frame.size.width / 2
        cell.circularImage.clipsToBounds = true
        cell.circularLabel.text = topic.name
        var index = indexPath.row
        if showSearchResults {
            
            index = topics.indexOf({ $0.name == topic.name })!
        }
        
        if seletedTopics[index] {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
    @IBAction func addBtnClickedAction(sender: AnyObject) {
        
        //upload interested topics to firebase
        var interestedTopicArray = [String]();
        if (showSearchResults){
            for topic in filteredTopics{
                let index = topics.indexOf({ $0.name == topic.name })
                if seletedTopics[index!] {
                    interestedTopicArray.append(topic.name)
                }
            }
        }else{
            for index in 0 ... topics.count-1{
                if(seletedTopics[index]){
                    interestedTopicArray.append(topics[index].name)
                }
               
            }
        }
   
        firebaseModel.updateInterestedTopics(model.user.uid,interestedTopicArray: interestedTopicArray)
        
        // go to profile detail page
        
        goToProfileDetailPage();
    }
    @IBAction func backBtnClickedAction(sender: AnyObject) {
        goToProfileDetailPage();
    }
    
    func goToProfileDetailPage(){
    let myStoryBoard = self.storyboard
        var backViewName = "ProfileDetailPage";
        if(!model.isSignUpDetailPage){
            backViewName = "ProfilePage";
        }
    let profileDetailPage = (myStoryBoard?.instantiateViewControllerWithIdentifier(backViewName))! as UIViewController
    self.presentViewController(profileDetailPage, animated: true, completion: nil)
    }

}
