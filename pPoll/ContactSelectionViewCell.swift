//
//  ContactSelectionViewCell.swift
//  pPoll
//
//  Created by WangXin on 16/9/12.
//  Copyright © 2016年 syle. All rights reserved.
//

import UIKit
import Firebase

class ContactSelectionViewCell: UITableViewCell {
    @IBOutlet var ContactName: UILabel!
    @IBOutlet var selectButton: UIButton!
    var selectState: Bool
    var bigSelectedButton: UIButton?
    var delegate: CustomTableViewCellDelegate?
    var account : Account?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        selectState = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.createView();
        self.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectState = false
        super.init(coder: aDecoder)
    }
    
    
    func kUIColorFromRGB(rgbValue : Int)->UIColor{
        return UIColor(colorLiteralRed: ((Float)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((Float)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((Float)(rgbValue & 0xFF))/255.0, alpha: 1.0)
    }
    
    func createView(){
        self.ContactName = UILabel(frame: CGRectMake(14, 18, UIScreen.mainScreen().bounds.width - 80, 14))
        self.ContactName.textColor = kUIColorFromRGB(0x666666)
        self.ContactName.font = UIFont.systemFontOfSize(14)
        
        self.ContactName.textAlignment = NSTextAlignment.Left;
        self.ContactName.frame = CGRectMake(14, 18, UIScreen.mainScreen().bounds.width - 80, 14);
        self.contentView.addSubview(self.ContactName)
        
        
        //选中按钮
        self.selectButton = UIButton(type: UIButtonType.Custom)
        self.selectButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 35, 15, 20, 20);
        self.selectButton.titleLabel?.text = "test by nick"
        self.selectButton.selected = self.selectState
        self.selectButton.setImage(UIImage(named: "cart_unSelect_btn"), forState: UIControlState.Normal)
        self.selectButton.setImage(UIImage(named: "cart_selected_btn"), forState: UIControlState.Selected)
        selectButton.addTarget(self, action: #selector(self.selectBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(selectButton)
        
        
        bigSelectedButton = UIButton(type: UIButtonType.Custom)
        bigSelectedButton!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.bounds.height)
        bigSelectedButton!.backgroundColor = UIColor.clearColor()
        bigSelectedButton!.addTarget(self, action: #selector(self.selectBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(bigSelectedButton!);
     
        
    }
    
    //选中按钮点击事件
    func selectBtnClick(button :UIButton)
    {
        self.selectButton.selected = !self.selectButton.selected;
        if(delegate != nil){
            delegate?.tableViewCell(self, isSelected: self.selectButton.selected)
        }
    }
    func reloadData() {
        self.ContactName.text = self.account?.username;
        
        self.selectButton.selected = self.selectState;
        
    }
    
    
    
    
}
