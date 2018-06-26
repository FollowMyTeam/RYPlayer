//
//  RYPromptConfig.swift
//  RongYaoTeamPrompt
//
//  Created by summer的Dad on 2018/6/23.
//  Copyright © 2018年 ZhuQiong. All rights reserved.
//

import UIKit

class RYPromptConfig {
    
    /// default is UIEdgeInsetsMake( 8, 8, 8, 8 ).
    public var insets: UIEdgeInsets!
    /// default is 8.
    public var cornerRadius: CGFloat!
    /// default is black.
    public var backgroundColor: UIColor!
    /// default is systemFont( 14 ).
    public var font: UIFont!
    /// default is white.
    public var fontColor: UIColor!
    /// default is ( superview.width * 0.6 ).
    public var maxWidth: CGFloat!
    
    
    init() {
       reset()
    }
    
    
    func reset() {
        
        insets = UIEdgeInsetsMake(8, 8, 8, 8)
        cornerRadius = 8
        backgroundColor = UIColor.black
        font = UIFont.systemFont(ofSize: 14)
        fontColor = UIColor.white
        maxWidth = 0
        
    }
    
}
