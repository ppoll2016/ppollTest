//
//  SelectTopicViewController.swift
//  pPoll
//
//  Created by Nath on 10/5/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Firebase

class SelectTopicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
    lazy var ref = FIRDatabase.database().reference()
    let model = Model.sharedInstance
    let firebaseModel = ModelFirebase.sharedInstance
    
    var topics = [Topic]()
    var filteredTopics = [Topic]()
    
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
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let publicQuestionCreationVC = segue.destinationViewController as! PublicQuestionCreationViewController
        
        if showSearchResults {
            let topic = filteredTopics[tableView.indexPathForSelectedRow!.row]
            publicQuestionCreationVC.topic = topic
            publicQuestionCreationVC.topicNameLabel.text = topic.name
        }
        else {
            let topic = topics[tableView.indexPathForSelectedRow!.row]
            publicQuestionCreationVC.topic = topic
            publicQuestionCreationVC.topicNameLabel.text = topic.name
        }
    }
}
