//
//  RYPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

//SJVideoPlayerPlayState_Unknown = 0,
//SJVideoPlayerPlayState_Prepare,
//SJVideoPlayerPlayState_Playing,
//SJVideoPlayerPlayState_Buffing,
//SJVideoPlayerPlayState_Paused,
//SJVideoPlayerPlayState_PlayEnd,
//SJVideoPlayerPlayState_PlayFailed,

public enum RYPlayerPlayState {
    case unknown
    case prepare
}

public protocol RYPlayerDelegate: NSObjectProtocol {
    /// 准备播放一个新的URL的回调
    func player(_ player: RYPlayer, prepareToPlay URL: URL?) -> Void
    
    /// 当前时间改变的回调
    func playerCurrentTimeDidChange(_ player: RYPlayer) -> Void
    
    /// 持续时间改变的回调
    func playerDurationDidChange(_ player: RYPlayer) -> Void
    
    /// 缓冲进度改变的回调
    func playerCurrentBufferLoadedTimeDidChange(_ player: RYPlayer) -> Void
    
    /// 状态改变的回调
    func playerStatusDidChange(_ player: RYPlayer) -> Void
    
    /// 缓冲区为空的回调
    func playerPlaybackBufferEmpty(_ player: RYPlayer) -> Void
    
    /// 缓冲区加满的回调
    func playerPlaybackBufferFull(_ player: RYPlayer) -> Void
    
    /// 视频呈现的大小
    func playerDidLoadPresentationSize(_ player: RYPlayer) -> Void
    
    /// 播放完毕的回调
    func playerDidPlayToEndTime(_ player: RYPlayer) -> Void
}


open class RYPlayer: NSObject {

    open var ry_URL: URL? {
        didSet {
            prepareToPlay(ry_URL)
        }
    }

    open var ry_view: UIView?
    
    open var ry_error: Error?
    
    open var state: RYPlayerPlayState
    
    open weak var ry_delegate: RYPlayerDelegate?
    
    open var ry_duration: TimeInterval? {
        return self.avPlayerItem?.ry_duration
    }
    
    open var ry_currentTime: TimeInterval? {
        return self.avPlayerItem?.ry_currentTime
    }
    
    open var ry_currentBufferLoadedTime: TimeInterval? {
        return self.avPlayerItem?.ry_currentBufferLoadedTime
    }
    
    public override init() {
        state = .unknown
        super.init()
        
    }
    
    deinit {
        
    }
    
    private var avAsset: AVURLAsset? {
        get {
            return self.avPlayerItem?.asset as? AVURLAsset
        }
    }
    
    private var avPlayerItem: RYAVPlayerItem? {
        get {
            return self.avPlayer?.ry_playerItem
        }
    }
    
    private var avPlayer: RYAVPlayer?
    
    private static var SERIAL_QUEUE: OperationQueue?
    
    private func prepareToPlay(_ newURL: URL?) {
        if ( ry_URL == nil ) {
            self.avPlayer = nil
            return
        }
        
        self.ry_delegate?.player(self, prepareToPlay: self.ry_URL)
        if ( RYPlayer.SERIAL_QUEUE == nil ) {
            RYPlayer.SERIAL_QUEUE = OperationQueue.init()
            RYPlayer.SERIAL_QUEUE?.name = "com.SJPlayer.serialQueue"
            RYPlayer.SERIAL_QUEUE?.maxConcurrentOperationCount = 1
        }
        
        RYPlayer.SERIAL_QUEUE?.addOperation({[weak self] in
            guard let `self` = self else {
                return
            }
            
            let asset = AVURLAsset.init(url: self.ry_URL!)
            let item = RYAVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            item.ry_delegate = self
            let player = RYAVPlayer.init(playerItem: item)
            player.ry_delegate = self
            player.play()
            self.avPlayer = player
        });
    }
}

/// play control
extension RYPlayer {
    
//    open var autoPlay: Bool = true
//    open var rate: Float?

    open func pause() {
        
    }
    
    open func play() {
        
    }
    
    open func stop() {
        
    }
    
    open func replay() {
        
    }
}

/// mute / volume / brightness
extension RYPlayer {

//    open var mute: Bool
//    open var volume: Float?
//    open var brightness: Float?
    
}

extension RYPlayer: RYAVPlayerItemDelegate, RYAVPlayerDelegate {
    public func playerItemDurationDidChange(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerDurationDidChange(self)
    }
    
    public func playerItemCurrentBufferLoadedTimeDidChange(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerCurrentBufferLoadedTimeDidChange(self)
    }
    
    public func playerItemStatusDidChange(_ playerItem: RYAVPlayerItem) {
//        self.delegate
    }
    
    public func playerItemPlaybackBufferEmpty(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerPlaybackBufferEmpty(self)
    }
    
    public func playerItemPlaybackBufferFull(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerPlaybackBufferFull(self)
    }
    
    public func playerItemDidLoadPresentationSize(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerDidLoadPresentationSize(self)
    }
    
    public func playerItemDidPlayToEndTime(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerDidPlayToEndTime(self)
    }
    
    public func playerCurrentTimeDidChange(_ player: RYAVPlayer) {
        self.ry_delegate?.playerCurrentTimeDidChange(self)
    }
}
