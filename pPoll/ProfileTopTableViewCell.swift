//
//  ContactSelectionViewCell.swift
//  pPoll
//
//  Created by WangXin on 16/9/12.
//  Copyright © 2016年 syle. All rights reserved.
//

import UIKit
import Firebase

class ProfileTopTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
    var photo: UIImageView!
    var selectState: Bool
    var bigSelectedButton: UIButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        selectState = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectState = false
        super.init(coder: aDecoder)
        //        self.createView();
    }
    
    
    func kUIColorFromRGB(rgbValue : Int)->UIColor{
        return UIColor(colorLiteralRed: ((Float)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((Float)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((Float)(rgbValue & 0xFF))/255.0, alpha: 1.0)
    }
    
    func createView(){
        self.frame = CGRectMake(0,0,self.frame.width,100)
        self.contentView.frame = self.frame
        //photo
        photo = UIImageView(frame: CGRectMake(5,5,self.contentView.frame.height-10,self.contentView.frame.height-10));
        print(self.frame)
        print(photo.frame)
        
        let imge = UIImage(named: "Contacts-52")
        print(imge!.size)
        photo.image = ResizeImage(imge!,targetSize: photo.frame.size)
        print(photo.frame)
        print(photo.image!.size)
        
        self.contentView.addSubview(photo)
        let fontSize = 28 as CGFloat;
        //user name
        self.username = UILabel(frame: CGRectMake(photo.frame.width+5, (self.contentView.frame.height-fontSize)/2, UIScreen.mainScreen().bounds.width - self.contentView.frame.height, fontSize))
        self.username.textColor = kUIColorFromRGB(0x666666)
        self.username.font = UIFont.systemFontOfSize(fontSize)
        self.username.text = "kelvin"
        self.username.textAlignment = NSTextAlignment.Center;
        self.username.frame = CGRectMake(photo.frame.width+5, (self.contentView.frame.height-fontSize)/2, UIScreen.mainScreen().bounds.width - self.contentView.frame.height, fontSize);
        
        self.contentView.addSubview(self.username)
        
        
        //        //选中按钮
        //
        //
        //
        //        bigSelectedButton = UIButton(type: UIButtonType.Custom)
        //        bigSelectedButton!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.bounds.height)
        //        bigSelectedButton!.backgroundColor = UIColor.clearColor()
        //        bigSelectedButton!.addTarget(self, action: #selector(self.selectBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        //        self.contentView.addSubview(bigSelectedButton!);
        
        
    }
    
    //    //选中按钮点击事件
    //    func selectBtnClick(button :UIButton)
    //    {
    //        self.selectButton.selected = !self.selectButton.selected;
    //    }
    //    func reloadDataWith(model : String) {
    //        self.ContactName.text = model;
    //
    //        self.selectButton.selected = self.selectState;
    //
    //    }
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}