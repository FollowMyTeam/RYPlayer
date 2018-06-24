//
//  RYPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public class RYPlayer {
    
    public var controlLayerDataSource: Any!
    
    public var controlLayerDelegate: Any!
    
    private var view: UIView { return player.view }
    
    private var player: RongYaoTeamPlayer!
}

