//
//  RYAVPlayerItem.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

public protocol RYAVPlayerItemDelegate: NSObjectProtocol {
    /// 持续时间改变的回调
    func playerItemDurationDidChange(_ playerItem: RYAVPlayerItem) -> Void;
    
    /// 缓冲进度改变的回调
    func playerItemCurrentBufferLoadedTimeDidChange(_ playerItem: RYAVPlayerItem) -> Void;
    
    /// 状态改变的回调
    func playerItemStatusDidChange(_ playerItem: RYAVPlayerItem) -> Void;
    
    /// 缓冲区为空的回调
    func playerItemPlaybackBufferEmpty(_ playerItem: RYAVPlayerItem) -> Void;
    
    /// 缓冲区加满的回调
    func playerItemPlaybackBufferFull(_ playerItem: RYAVPlayerItem) -> Void;
    
    /// 视频呈现的大小
    func playerItemDidLoadPresentationSize(_ playerItem: RYAVPlayerItem) -> Void;
    
    /// 播放完毕的回调
    func playerItemDidPlayToEndTime(_ playerItem: RYAVPlayerItem) -> Void;
}

public class RYAVPlayerItem: AVPlayerItem {
    
    /// 代理
    /// 回调请看协议
    open weak var ry_delegate: RYAVPlayerItemDelegate?

    /// 持续时间
    /// 单位秒
    open var ry_duration: TimeInterval? {
        get {
            return self._ry_duration
        }
    }
    private var _ry_duration: TimeInterval?
    
    /// 当前时间
    /// 单位秒
    open var ry_currentTime: TimeInterval {
        get {
            if ( self.ry_duration == nil ) {
                return 0
            }
            
            return CMTimeGetSeconds(self.currentTime())
        }
    }
    
    /// 当前缓冲加载到的位置
    /// 单位秒
    open var ry_currentBufferLoadedTime: TimeInterval {
        get {
            if ( self.loadedTimeRanges.first == nil ) {
                return 0;
            }
            
            let range = self.loadedTimeRanges.first!.timeRangeValue
            return TimeInterval.init(CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration))
        }
    }
    
    public override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.ry_addKeyObservers()
    }
    
    deinit {
        self.ry_removeKeyObservers()
    }
}

/// handle buffer empty
private extension RYAVPlayerItem {
    struct RYAVPlayerItemHandleBufferAssociatedKeys {
        /// 用于刷新当前的缓冲进度
        /// 此timer将会每2秒刷新一次
        /// 缓冲进度 > ry_maxPreTime, 代表可以继续播放
        static var ry_refreshBufferTimer: Timer?
        
        /// 是否正在等待缓冲
        static var ry_isWaitingPlaybackBuffer: Bool?
    }
    
    /// 最长准备时间(缓冲)可以播放
    /// 单位秒
    var ry_maxPreTime: TimeInterval {
        get {
            let max = self.ry_duration
            if ( max == nil ) {
                return 0
            }
            let pre = self.ry_currentTime + 5
            return pre < max! ? pre : max!
        }
    }
    
    /// 轮询缓冲, 查看是否可以继续播放
    func ry_pollingPlaybackBuffer() {
        if ( RYAVPlayerItemHandleBufferAssociatedKeys.ry_isWaitingPlaybackBuffer == true ) {
            return
        }
        
        let ry_refreshBufferTimer = Timer.sj_timer(interval: 2, block: { [weak self] (timer) in
            guard let `self` = self else {
                timer.invalidate()
                return
            }
            
            let duration = self.ry_duration
            if ( duration == nil ) {
                return
            }
            
            let pre_buffer = self.ry_maxPreTime;
            let currentBufferLoadedTime = self.ry_currentBufferLoadedTime
            if ( pre_buffer > currentBufferLoadedTime ) {
                return
            }
            
            timer.invalidate()
            RYAVPlayerItemHandleBufferAssociatedKeys.ry_isWaitingPlaybackBuffer = false
            self.ry_delegate?.playerItemPlaybackBufferFull(self)
        }, repeats: true)
        
        RunLoop.main.add(ry_refreshBufferTimer, forMode: .commonModes)
        ry_refreshBufferTimer.fireDate = Date.init(timeIntervalSinceNow: ry_refreshBufferTimer.timeInterval)
        RYAVPlayerItemHandleBufferAssociatedKeys.ry_refreshBufferTimer = ry_refreshBufferTimer
    }
}


/// observers
private  extension RYAVPlayerItem  {
    struct RYAVPlayerItemObserverAssociatedKeys {
        static var ry_ownerObservers = [RYOwnerObserver]()
    }
    
    func ry_addKeyObservers() {
        RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "duration", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self._ry_duration = CMTimeGetSeconds(self.duration)
            self.ry_delegate?.playerItemDurationDidChange(self)
        }))
        
        RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "loadedTimeRanges", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_delegate?.playerItemCurrentBufferLoadedTimeDidChange(self)
        }))
        
        RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "status", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_delegate?.playerItemStatusDidChange(self)
        }))
        
        RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "playbackBufferEmpty", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_delegate?.playerItemPlaybackBufferEmpty(self)
            self.ry_pollingPlaybackBuffer()
        }))
        
        RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "presentationSize", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_delegate?.playerItemDidLoadPresentationSize(self)
        }))
        
        RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, nota: NSNotification.Name.AVPlayerItemDidPlayToEndTime, exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_delegate?.playerItemDidPlayToEndTime(self)
        }))
    }
    
    func ry_removeKeyObservers() {
        let helpers = RYAVPlayerItemObserverAssociatedKeys.ry_ownerObservers
        for kvo in helpers {
            kvo.remove(owner: self)
        }
    }
}
