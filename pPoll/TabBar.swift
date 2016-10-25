//
//  TabBar.swift
//  pPoll
//
//  Created by syle on 11/10/2016.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    func setBadges(badgeValues: [Int]) {
        
        for view in self.tabBar.subviews {
            if view is CustomTabBadge {
                view.removeFromSuperview()
            }
        }
        
        for index in 0...badgeValues.count-1 {
            if badgeValues[index] != 0 {
                addBadge(index, value: badgeValues[index])
            }
        }
    }
    
    func addBadge(index: Int, value: Int) {
        let badgeView = CustomTabBadge()
        
        badgeView.adjustsFontSizeToFitWidth = true
        badgeView.minimumScaleFactor = 0.5
        badgeView.clipsToBounds = true
        badgeView.textColor = UIColor.whiteColor()
        badgeView.textAlignment = .Center
        badgeView.font = UIFont.systemFontOfSize(11)
        badgeView.text = String(value)
        badgeView.backgroundColor = UIColor(red: 83/255, green: 216/255, blue: 212/255, alpha:1.0)

        badgeView.tag = index
        tabBar.addSubview(badgeView)
        
        self.positionBadges()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBar.setNeedsLayout()
        self.tabBar.layoutIfNeeded()
        self.positionBadges()
    }
    
    // Positioning
    func positionBadges() {
        
        var tabbarButtons = self.tabBar.subviews.filter { (view: UIView) -> Bool in
            return view.userInteractionEnabled // only UITabBarButton are userInteractionEnabled
        }
        
        tabbarButtons = tabbarButtons.sort({ $0.frame.origin.x < $1.frame.origin.x })
        
        for view in self.tabBar.subviews {
            if view is CustomTabBadge {
                let badgeView = view as! CustomTabBadge
                self.positionBadge(badgeView, items:tabbarButtons, index: badgeView.tag)
            }
        }
    }
    
    func positionBadge(badgeView: UIView, items: [UIView], index: Int) {
        
        let itemView = items[index]
        let center = itemView.center
        
        let xOffset: CGFloat = 18
        let yOffset: CGFloat = -14
        badgeView.frame.size = CGSizeMake(20, 20)
        badgeView.center = CGPointMake(center.x + xOffset, center.y + yOffset)
        badgeView.layer.cornerRadius = badgeView.bounds.width/2
        tabBar.bringSubviewToFront(badgeView)
    }
}

class CustomTabBadge: UILabel {}