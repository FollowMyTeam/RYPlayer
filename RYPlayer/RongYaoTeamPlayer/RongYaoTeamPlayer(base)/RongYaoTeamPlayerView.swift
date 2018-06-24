//
//  RongYaoTeamPlayerView.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/19.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - 播放器视图

/// RongYaoTeamPlayerView - 播放器视图
/// - 呈现
public class RongYaoTeamPlayerView: UIView {

    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    public var avVideoGravity: AVLayerVideoGravity = AVLayerVideoGravity.resizeAspect { didSet{ self.playerLayer.videoGravity = avVideoGravity } }
    
    public func setAVPlayer(_ avPlayer: AVPlayer?) {
        if ( avPlayer == self.playerLayer.player ) { return }
        self.playerLayer.player = avPlayer
    }
    
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
}
