//
//  RongYaoEdgeControlLayerBottomView.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

/// 边缘控制层 - 下

public class RongYaoEdgeControlLayerBottomView: RongYaoEdgeControlLayerView {
    
    public override var intrinsicContentSize: CGSize {
        var height: CGFloat = 49
        if let `player` = player {
            if player.view.rotationManager.isFullscreen {
                height = 60
            }
        }
        return CGSize.init(width: UIScreen.main.bounds.width, height: height)
    }
}
