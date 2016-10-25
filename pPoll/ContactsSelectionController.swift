//
//  ContactsSelectionController.swift
//  pPoll
//
//  Created by WangXin on 16/9/12.
//  Copyright © 2016年 syle. All rights reserved.
//

import Foundation

import UIKit
import Firebase

class ContactsSelectionController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,CustomTableViewCellDelegate {
    lazy var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    
    let firebaseModel = ModelFirebase.sharedInstance
    
    //select all flag
    var selectAll :UIButton!;
    //select flag
    var isSelect = false;
    var showSearchResults = false
    var contacts = [Account]();
    let model = Model.sharedInstance
    var filteredContacts = [Account]()
    //selected contacts
    var selectContacts = [Account]();
    
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
        //        searchAccounts()
        self.createTableView();
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard:"))
        self.view.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "hideKeyboard:"))
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "hideKeyboard:"))
        self.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "hideKeyboard:"))
        
    }
    
    func loadContacts(){
        self.contacts = model.accounts
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //clear selectContacts
        selectContacts.removeAll()
        isSelect = false;
        selectAll.selected = false;
    }
    
    
    @IBAction func backBtnClickAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func randomData()->NSString{
        return NSString.localizedStringWithFormat("Person-%d", arc4random_uniform(1000))
    }
    
    func createTableView() {
        
        self.contactTableView.delegate = self;
        self.contactTableView.dataSource = self;
        self.searchBar.delegate = self;
        self.contactTableView.showsVerticalScrollIndicator = false;
        self.contactTableView.rowHeight = 50;
        self.view.addSubview(self.contactTableView)
        self.createTopView();
        
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        print("searchBarResultsListButtonClicked")
    }
    
    
    
    func createTopView() {
        
        
        var topView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 60))
        var label = UILabel()
        label.text = "Select All";
        label.font = UIFont.systemFontOfSize(20);
        label.textColor = UIColor.blackColor();
        label.textAlignment = NSTextAlignment.Left;
        label.frame = CGRectMake(15, 20, 220, 20);
        topView.addSubview(label);
        
        //Select all Btn
        selectAll = UIButton(type: UIButtonType.Custom)
        selectAll.titleLabel?.font = UIFont.systemFontOfSize(15)
        selectAll.setImage(UIImage(named: "cart_unSelect_btn"), forState: UIControlState.Normal)
        selectAll.frame = CGRectMake(15, 10, UIScreen.mainScreen().bounds.width - 30, 30);
        selectAll.setImage(UIImage(named: "cart_selected_btn"), forState: UIControlState.Selected)
        
        selectAll.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        selectAll.addTarget(self, action: #selector(selectAllBtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //    selectAll.backgroundColor = [UIColor lightGrayColor];
        selectAll.setTitle("        ", forState: UIControlState.Normal)
        selectAll.imageEdgeInsets = UIEdgeInsetsMake(0,UIScreen.mainScreen().bounds.width - 50,0,selectAll.titleLabel!.bounds.size.width)
        topView.addSubview(selectAll)
        
        topView.backgroundColor = UIColor.whiteColor()
        let line:UILabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 0.5))
        line.backgroundColor = UIColor.lightGrayColor();
        topView.addSubview(line);
        self.contactTableView.tableHeaderView = topView;
    }
    
    func selectAllBtnClick(button:UIButton)
    {
        //before do the action selecting all ,clear selectGoods array
        selectContacts.removeAll()
        
        button.selected = !button.selected;
        self.isSelect = button.selected;
        if (isSelect == true) {
            for  model in contacts {
                selectContacts.append(model)
            }
        }
        else{
            selectContacts.removeAll()        }
        self.contactTableView.reloadData();
        self.view.endEditing(true)
    }
    
    // 返回行的个数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if showSearchResults {
            return filteredContacts.count
        }else {
            return contacts.count
        }
    }
    //返回列的个数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    //返回一个cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "ProductTableViewCell";
        var contactcell = tableView.dequeueReusableCellWithIdentifier(identifier) ;
        let contact : Account
        
        //        if showSearchResults {
        //            contact = filteredContacts[indexPath.row]
        //        }
        //        else {
        contact = contacts[indexPath.row]
        //        }
        
        if(contactcell == nil){
            let contactSelectionViewCell = ContactSelectionViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            
            contactcell = contactSelectionViewCell
        }
        
        contactcell!.selectionStyle = UITableViewCellSelectionStyle.None;
        let temp :ContactSelectionViewCell = contactcell as! ContactSelectionViewCell
        temp.account = contact;
        temp.delegate = self
        temp.selectState = self.selectContacts.contains(contact)
        temp.reloadData()
        return temp
    }
    
    
    @IBAction func saveClickButton(sender: AnyObject) {
        var str = "" as NSString;
        firebaseModel.updateContacts(model.user.uid, contacts: selectContacts);
        model.assignContacts(selectContacts)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchAccounts(keywords : String){
        //        ref.child("Accounts").observeEventType(.Value, withBlock: { (snapshot) in let
        //            accountSnapshot = snapshot.value as! [String: AnyObject]
        //            if(accountSnapshot.count > 0){
        //                self.contacts.removeAll()
        //                for (key,_) in accountSnapshot {
        //                    let value = accountSnapshot[key] as! [String:AnyObject];
        //                    let new = Account(uid: key, snapshot: value)
        //                    self.contacts.append(new)
        //                }
        //
        //            }
        //        })
        ref.child("Accounts").queryOrderedByChild("username").queryStartingAtValue(keywords).queryEndingAtValue(keywords+"\u{f8ff}").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let accountSnapshot = snapshot.value as? [String: AnyObject]
            if accountSnapshot != nil {
                self.contacts.removeAll()
                
                for (key,accountValue) in accountSnapshot! {
                    let account = Account(uid: key, snapshot: accountValue as! [String : AnyObject])
                    if (!self.model.user.contacts.contains(account) && account.uid != self.model.user.uid) {
                        self.contacts.append(account)
                        print(account.username)
                        self.contactTableView.reloadData()
                    }
                }
            }
        })
    }
    // methods from searchbar delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            searchAccounts(searchText)
            //            filteredContacts = contacts.filter({ (contact : Account) -> Bool in
            //                contact.username.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            //            })
            //            showSearchResults = true
            contactTableView.reloadData()
        }
        else {
            self.loadContacts()
            //            showSearchResults = false
            contactTableView.reloadData()
        }
    }
    
    
    func hideKeyboard(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            print("收回键盘")
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    @IBAction func CancelBtnClickedAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func tableViewCell(tableViewCell: UITableViewCell, isSelected: Bool) {
        let cell = tableViewCell as! ContactSelectionViewCell
        if(isSelected && !selectContacts.contains(cell.account!)){
            selectContacts.append(cell.account!)
        }else if (!isSelected && selectContacts.contains(cell.account!)){
            selectContacts.removeAtIndex(selectContacts.indexOf(cell.account!)!)
        }
    }
    
}