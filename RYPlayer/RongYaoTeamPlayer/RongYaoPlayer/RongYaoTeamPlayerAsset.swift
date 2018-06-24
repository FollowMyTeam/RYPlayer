//
//  RongYaoTeamPlayerAsset.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

/// 播放器资源
/// 使用两个参数进行初始化分别如下:
/// - URL
/// - 播放的开始时间
public class RongYaoTeamPlayerAsset {
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayerAsset")
        #endif
    }
    
    /// 创建一个Asset
    ///
    /// - Parameters:
    ///   - playURL: 播放的URL(本地/远程)
    ///   - specifyStartTime: 从指定时间开始播放, 默认为0
    public init(_ playURL: URL, specifyStartTime: TimeInterval) {
        self.specifyStartTime = specifyStartTime
        self.playURL = playURL
    }
    
    public convenience init(_ playURL: URL) { self.init(playURL, specifyStartTime: 0) }
    
    public private(set) var playURL: URL
    public private(set) var specifyStartTime: TimeInterval = 0

    
    
    public init(_ otherAsset: RongYaoTeamPlayerAsset) {
        playURL = otherAsset.playURL
        specifyStartTime = otherAsset.specifyStartTime
        self.otherAsset = otherAsset
    }
    
    public private(set) var otherAsset: RongYaoTeamPlayerAsset?
    public var isOtherAsset: Bool { return otherAsset != nil }
}
