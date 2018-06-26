//
//  RongYaoButtonItem.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/26.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public class RongYaoButtonItem {
    public init(_ image: UIImage, target: AnyObject, action: Selector) {
        self.image = image
        self.target = target
        self.action = action
    }
    
    public init(_ title: NSAttributedString, target: AnyObject, action: Selector) {
        self.title = title
        self.target = target
        self.action = action
    }
    
    public init(_ customView: UIView) {
        self.customView = customView
    }
    
    /// default is false
    @objc public dynamic var isHidden: Bool = false
    
    /// default is 0.0
    @objc public dynamic var width: CGFloat = 0.0
    
    @objc public dynamic var image: UIImage?
    
    @objc public dynamic var title: NSAttributedString?
    
    @objc public dynamic var customView: UIView?
    
    public var action: Selector?
    
    public weak var target: AnyObject?
}
