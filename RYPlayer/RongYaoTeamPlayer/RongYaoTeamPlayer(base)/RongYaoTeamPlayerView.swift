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
/// - 旋转
public class RongYaoTeamPlayerView: UIView {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayerView")
        #endif
        presentView.removeFromSuperview()
    }
    
    /// 呈现
    public var presentView: RongYaoTeamPlayerPresentView!
    
    /// 旋转
    public var rotationManager: RongYaoTeamRotationManager!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        presentView = RongYaoTeamPlayerPresentView.init(frame: .zero)
        presentView.backgroundColor = .black
        presentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(presentView)
        rotationManager = RongYaoTeamRotationManager.init(target: presentView, superview: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class RongYaoTeamPlayerPresentView: UIView {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayerView")
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
