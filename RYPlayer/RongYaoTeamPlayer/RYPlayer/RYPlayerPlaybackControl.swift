//
//  RYPlayerPlaybackControl.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import Foundation

public protocol RongYaoTeamPlayerPlaybackControl {
    
    /// 是否静音
    var mute: Bool { get set }
    
    /// 是否自动播放
    var autoplay: Bool { get set }
    
    /// app进入后台是否暂停播放
    var pauseWhenAppDidEnterBackground: Bool { get set }
    
    func play()
    
    func pause()
    
    func stop()
    
    func replay()
}
