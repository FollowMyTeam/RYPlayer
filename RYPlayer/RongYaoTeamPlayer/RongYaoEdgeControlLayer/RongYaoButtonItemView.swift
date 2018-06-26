//
//  RongYaoButtonItemView.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/26.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public class RongYaoButtonItemView: UIControl {
    init(_ item: RongYaoButtonItem) {
        super.init(frame: .zero)
        self.item = item
    }
    
    public var item: RongYaoButtonItem?
}
