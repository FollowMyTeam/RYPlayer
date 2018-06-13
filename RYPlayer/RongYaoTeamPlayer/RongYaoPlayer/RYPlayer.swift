//
//  RYPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation


/// 播放器当前的状态
///
/// - unknown: 未播放任何资源时的状态
/// - prepare: 准备播放一个新的资源时的状态
/// - playing: 播放中
/// - buffering: 缓冲中
/// - pause: 暂停
/// - playEnd: 播放结束
/// - playFailed: 播放失败
public enum RYPlayerPlayState {
    case unknown
    case prepare
    case playing
    enum paused {
        case buffering
        case pause
    }
    enum stopped {
        case playEnd
        case playFailed
    }
}

public protocol RYPlayerDelegate: NSObjectProtocol {
    /// 播放一个新的URL的回调
    /// 当设置`player.ry_URL`时, 将回调此方法
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


public class RYPlayer: NSObject {

    @objc public dynamic var ry_URL: URL?

    public var ry_view: UIView?
    
    public var ry_error: Error?
    
    public var ry_state: RYPlayerPlayState
    
    public weak var ry_delegate: RYPlayerDelegate?
    
    public override init() {
        ry_state = .unknown
        super.init()
        ry_addKeyObservers()
    }
    
    deinit {
        ry_cancelInitOperation()
        ry_removeKeyObservers()
    }
    
    private var ry_avAsset: AVURLAsset? { return self.ry_avPlayerItem?.asset as? AVURLAsset }
    private var ry_avPlayerItem: RYAVPlayerItem? { return self.ry_avPlayer?.ry_playerItem }
    private var ry_avPlayer: RYAVPlayer?
    
    private var ry_ownerObservers = [RYOwnerObserver]()
    private func ry_addKeyObservers() {
        /// URL
        self.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "ry_URL", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_prepareToPlay(self.ry_URL)
        }))
    }
    private func ry_removeKeyObservers () {
        for helper in ry_ownerObservers {
            helper.remove(owner: self)
        }
    }
}

/// 播放器的初始化
private extension RYPlayer {
    
    struct RYPlayerInitPlayerAssociatedKeys {
        static var kry_initOperation = "kry_initOperation"
    }

    /// 用来初始化Player的队列
    static var SERIAL_QUEUE: OperationQueue?
    
    /// 初始化的操作对象
    var ry_initOperation: Operation? {
        set {
            objc_setAssociatedObject(self, &RYPlayerInitPlayerAssociatedKeys.kry_initOperation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &RYPlayerInitPlayerAssociatedKeys.kry_initOperation) as? Operation
        }
    }

    /// 播放一个新的URL
    func ry_prepareToPlay(_ newURL: URL?) {
        if ( ry_URL == nil ) {
            ry_avPlayer = nil
            return
        }
        
        ry_delegate?.player(self, prepareToPlay: newURL)
        
        ry_cancelInitOperation()
        
        ry_addOperationToQueue()
    }
    
    /// 取消之前的操作并置空
    func ry_cancelInitOperation() {
        guard let `initOperation` = ry_initOperation else {
            return
        }
        
        if ( !initOperation.isFinished && !initOperation.isExecuting && !initOperation.isCancelled ) {
            initOperation.cancel()
        }
        
        self.ry_initOperation = nil
    }
    
    /// 添加初始化任务到队列
    func ry_addOperationToQueue() {
        if ( ry_initOperation != nil ) {
            ry_cancelInitOperation()
        }
        
        ry_initOperation = Operation.init()
        
        ry_initOperation?.completionBlock = { [weak self] in
            guard let `self` = self else {
                return
            }
            let asset = AVURLAsset.init(url: self.ry_URL!)
            let item = RYAVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            item.ry_delegate = self
            let player = RYAVPlayer.init(playerItem: item)
            player.ry_delegate = self
            self.ry_avPlayer = player
            self.ry_initOperation = nil
        }
        
        if ( RYPlayer.SERIAL_QUEUE == nil ) {
            RYPlayer.SERIAL_QUEUE = OperationQueue.init()
            RYPlayer.SERIAL_QUEUE?.name = "com.SJPlayer.serialQueue"
            RYPlayer.SERIAL_QUEUE?.maxConcurrentOperationCount = 1
        }
        
        RYPlayer.SERIAL_QUEUE?.addOperation(ry_initOperation!)
    }
}


public extension RYPlayer {
    /// 播放时长
    var ry_duration: TimeInterval? {
        return self.ry_avPlayerItem?.ry_duration
    }
    
    /// 当前时间
    var ry_currentTime: TimeInterval? {
        return self.ry_avPlayerItem?.ry_currentTime
    }
    
    /// 已缓冲到的时间
    var ry_bufferLoadedTime: TimeInterval? {
        return self.ry_avPlayerItem?.ry_bufferLoadedTime
    }
}

/// play control
public extension RYPlayer {
    
//    open var autoPlay: Bool = true
//    open var rate: Float?

    func pause() {
        
    }
    
    func play() {
        
    }
    
    func stop() {
        
    }
    
    func replay() {
        
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
