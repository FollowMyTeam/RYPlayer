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
    
    public override init() {
        super.init()
    }
    
    public override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        self.ry_observeTimeChangeOfCurrentTime()
    }
    
    deinit {
        self.pause()
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        self.ry_removeCurrentTiemObserver()
    }
}

/// 处理当前时间变更的回调
private extension RYAVPlayer {
    private struct RYAVPlayerHandleCurrentTimeChangeAssociatedKeys {
        static var kry_currentTimeObserver = "kry_currentTimeObserver"
    }
    
    var ry_currentTimeObserver: Any? {
        set {
            objc_setAssociatedObject(self, &RYAVPlayerHandleCurrentTimeChangeAssociatedKeys.kry_currentTimeObserver, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &RYAVPlayerHandleCurrentTimeChangeAssociatedKeys.kry_currentTimeObserver)
        }
    }
    
    private func ry_observeTimeChangeOfCurrentTime() {
        ry_currentTimeObserver = self.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else {
                return
            }
            self.ry_delegate?.playerCurrentTimeDidChange(self)
        })
    }
    
    private func ry_removeCurrentTiemObserver() {
        if ( ry_currentTimeObserver != nil ) {
            self.removeTimeObserver(ry_currentTimeObserver!)
        }
    }
}
