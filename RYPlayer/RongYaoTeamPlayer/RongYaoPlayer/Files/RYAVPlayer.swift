//
//  RYAVPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

internal protocol RYAVPlayerDelegate: NSObjectProtocol {
    /// 当前播放时间改变的回调
    func playerCurrentTimeDidChange(_ player: RYAVPlayer) -> Void
    
}

internal class RYAVPlayer: AVPlayer {
    /// 代理
    /// 回调请看协议
    weak var ry_delegate: RYAVPlayerDelegate?

    /// 当前播放器的playerItem如果类型为RY, 则返回
    var ry_playerItem: RYAVPlayerItem? {
        get {
            if ( self.currentItem == nil ) {
                return nil
            }
            
            if ( self.currentItem!.isKind(of: RYAVPlayerItem.self) ) {
                return self.currentItem as? RYAVPlayerItem
            }
            return nil
        }
    }
    
    var ry_currentTime: TimeInterval = 0
    
    public override init() {
        super.init()
        ry_observeTimeChangeOfCurrentTime()
    }
    
    public override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
    }
    
    deinit {
        pause()
        ry_removeCurrentTiemObserver()
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    private var ry_currentTimeObserver: Any?
    
    private func ry_observeTimeChangeOfCurrentTime() {
        ry_currentTimeObserver = self.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else {
                return
            }
            self.ry_currentTime = TimeInterval.init(CMTimeGetSeconds(time))
            self.ry_delegate?.playerCurrentTimeDidChange(self)
        })
    }
    
    private func ry_removeCurrentTiemObserver() {
        if ( ry_currentTimeObserver != nil ) {
            self.removeTimeObserver(ry_currentTimeObserver!)
        }
    }
}
