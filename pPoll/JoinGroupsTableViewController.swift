//
//  JoinGroupsTableViewController.swift
//  pPoll
//
//  Created by Nath on 8/13/16.
//  Copyright © 2016 Nath. All rights reserved.
//

import UIKit
import Foundation

class JoinGroupsTableViewController : UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var model = Model.sharedInstance
    
    var availableGroups = [Group]()
    var filteredAvailableGroups = [Group]()
    var showSearchResults  = false
    
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        navigationController?.navigationBar.hidden = false
        self.definesPresentationContext = true
        
        for group in model.groups {
            if !group.members.contains(model.user) {
                availableGroups.append(group)
            }
        }
        
        configureSearchController()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResults {
            return filteredAvailableGroups.count
        }
        else {
            return availableGroups.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell")
        
        if showSearchResults {
            let group = filteredAvailableGroups[indexPath.row]
            cell?.textLabel?.text = group.name
        }
        else {
            let group = availableGroups[indexPath.row]
            cell?.textLabel?.text = group.name
        }
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passGroupInfo" {
            let viewController = segue.destinationViewController as! GroupDetailsViewController
            if showSearchResults {
                viewController.group = filteredAvailableGroups[(self.tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                viewController.group = availableGroups[(self.tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
    
    func configureSearchController () {
        // Customize search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsCancelButton = true
        
        // Add it to the head of the table view
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        showSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        showSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !showSearchResults {
            showSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        if searchString == "" {
            showSearchResults = false
        }
        else {
            showSearchResults = true
            
            // Check both the group name and the topics of the group
            filteredAvailableGroups = availableGroups.filter({ (group) in filterResults(searchString!, group: group)})
        }
        
        tableView.reloadData()
    }
    
    func filterResults(searchString : String, group : Group) -> Bool {
        if (NSString(string: group.name).rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
            return true
        }
        
        for topic in group.topics {
            if (NSString(string: topic.name).rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound {
                return true
            }
        }
        
        return false
    }
}
