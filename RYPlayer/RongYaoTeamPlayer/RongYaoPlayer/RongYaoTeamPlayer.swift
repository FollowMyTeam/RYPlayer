//
//  RongYaoTeamPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation


/// 播放暂停的理由
///
/// - buffering: 缓冲中
/// - pause: 暂停播放
public enum RongYaoTeamPlayerPausedReason {
    case buffering
    case pause
}
/// 播放停止的原因
///
/// - playEnd: 播放完毕
/// - playFailed: 播放失败
public enum RongYaoTeamPlayerStoppedReason {
    case playEnd
    case playFailed
}
/// 播放器当前的状态
///
/// - unknown: 未播放任何资源时的状态
/// - prepare: 准备播放一个新的资源时的状态
/// - playing: 播放中
/// - paused:  暂停状态
/// - stopped: 停止状态
public enum RYPlayState {
    case unknown
    case prepare
    case playing
    case paused(reason: RongYaoTeamPlayerPausedReason)
    case stopped(reason: RongYaoTeamPlayerStoppedReason)
}
/// 播放器的一些公开属性
///
/// - ry_URL: 同 RongYaoTeamPlayer.ry_URL
/// - ry_state: 同 RongYaoTeamPlayer.ry_state
/// - ry_duration: 同 RongYaoTeamPlayer.ry_duration
/// - ry_currentTime: 同 RongYaoTeamPlayer.ry_currentTime
/// - ry_bufferLoadedTime: 同 RongYaoTeamPlayer.ry_bufferLoadedTime
/// - ry_bufferState: 同 RongYaoTeamPlayer.ry_bufferState
/// - ry_presentationSize: 同 RongYaoTeamPlayer.ry_presentationSize
public enum RongYaoTeamPlayerValueKey {
    case ry_URL
    case ry_state
    case ry_duration
    case ry_currentTime
    case ry_bufferLoadedTime
    case ry_bufferState
    case ry_presentationSize
}
/// 缓冲的状态
///
/// - unknown: 未知, 可能还未播放
/// - empty: 缓冲区为空
/// - full: 缓冲区已满
public enum RongYaoTeamPlayerBufferState {
    case unknown
    case empty
    case full
}

public protocol RongYaoTeamPlayerDelegate: NSObjectProtocol {
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey: RongYaoTeamPlayerValueKey) -> Void
}


public class RongYaoTeamPlayer: NSObject {
    /// 播放的资源URL
    @objc public dynamic var ry_URL: URL?
    
    /// 播放状态
    public private(set) var ry_state: RYPlayState = .unknown
    
    /// 播放时长
    public private(set) var ry_duration: TimeInterval = 0
    
    /// 当前时间
    public private(set) var ry_currentTime: TimeInterval = 0

    /// 已缓冲到的时间
    public private(set) var ry_bufferLoadedTime: TimeInterval = 0
    
    /// 缓冲状态
    public private(set) var ry_bufferState: RongYaoTeamPlayerBufferState = .unknown
    
    ///
    public private(set) var ry_presentationSize: CGSize = CGSize.zero
    
    /// 播放器视图
    public var ry_view: UIView?
    
    /// 播放报错时的error
    public var ry_error: Error?
    
    /// 代理
    public weak var ry_delegate: RongYaoTeamPlayerDelegate?
    
    private var ry_asset: AVURLAsset? { return self.ry_playerItem?.asset as? AVURLAsset }
    
    private var ry_playerItem: RYAVPlayerItem? { return self.ry_player?.ry_playerItem }
    
    private var ry_player: RYAVPlayer?
    
    public override init() {
        super.init()
        ry_addKeyObservers()
        
        ry_state = .stopped(reason: .playEnd)
        
        print(ry_state)
        
        print(ry_state)
    }
    
    deinit {
        ry_cancelInitOperation()
        ry_removeKeyObservers()
    }
    
    
    /// 观察`ry_URL`的变更
    /// 观察 ...
    private var ry_ownerObservers = [RYOwnerObserver]()
    
    ///
    private func ry_addKeyObservers() {
        /// URL
        self.ry_ownerObservers.append(RYOwnerObserver.init(owner: self, observeKey: "ry_URL", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_prepareToPlay(self.ry_URL)
        }))
    }
    
    ///
    private func ry_removeKeyObservers () {
        for helper in ry_ownerObservers {
            helper.remove(owner: self)
        }
    }
}


public extension RongYaoTeamPlayer {
    
    
}

/// 播放器的初始化
/// 用来初始化一个RYAVPlayer
/// 由于创建耗时, 这里将初始化放到了子线程中
private extension RongYaoTeamPlayer {
    
    struct RongYaoTeamPlayerInitPlayerAssociatedKeys {
        static var kry_initOperation = "kry_initOperation"
    }

    /// 用来初始化Player的队列
    /// 由于创建耗时所以, 将初始化任务放到了这个队列中
    /// 使用队列便于管理操作对象, 在某个时刻可以进行取消任务
    static var SERIAL_QUEUE: OperationQueue?
    
    /// 初始化的操作对象
    /// `创建一个RYAVPlayer`的操作任务
    var ry_initOperation: Operation? {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_initOperation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_initOperation) as? Operation
        }
    }

    /// 准备播放一个新的URL
    /// 此时, 将操作任务添加到队列中
    /// 同时取消上一次可能存在的任务
    func ry_prepareToPlay(_ newURL: URL?) {
        
        // clean old avplayer
        ry_player = nil

        if ( ry_URL == nil ) {
            return
        }
        
        ry_cancelInitOperation()
        
        ry_addOperationToQueue()
    }
    
    /// 取消之前的操作并将操作对象置空
    /// 当操作对象`未完成`&`未进行`&`未取消`时, 将其取消
    /// 最后操作对象置为nil
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
    /// 由于创建一个AVPlayer耗时, 因此将其放入子线程进行操作
    /// 当队列为空时, 这里进行了队列的初始化工作
    func ry_addOperationToQueue() {
        if ( ry_initOperation != nil ) {
            ry_cancelInitOperation()
        }
        
        ry_initOperation = Operation.init()
        
        ry_initOperation?.completionBlock = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // create AVURLAsset
            let asset = AVURLAsset.init(url: self.ry_URL!)
            
            // create RYPalyerItem
            let item = RYAVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            item.ry_delegate = self
            
            // create RYAVPlayer
            let player = RYAVPlayer.init(playerItem: item)
            player.ry_delegate = self
            
            // retain
            self.ry_player = player
            
            // clean operation object
            self.ry_initOperation = nil
        }
        
        if ( RongYaoTeamPlayer.SERIAL_QUEUE == nil ) {
            RongYaoTeamPlayer.SERIAL_QUEUE = OperationQueue.init()
            RongYaoTeamPlayer.SERIAL_QUEUE?.name = "com.SJPlayer.serialQueue"
            RongYaoTeamPlayer.SERIAL_QUEUE?.maxConcurrentOperationCount = 1
        }
        
        RongYaoTeamPlayer.SERIAL_QUEUE?.addOperation(ry_initOperation!)
    }
}

/// play control
public extension RongYaoTeamPlayer {
    
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
extension RongYaoTeamPlayer {

//    open var mute: Bool
//    open var volume: Float?
//    open var brightness: Float?
    
}

extension RongYaoTeamPlayer: RYAVPlayerItemDelegate, RYAVPlayerDelegate {
    func playerItemDurationDidChange(_ playerItem: RYAVPlayerItem) {
//        self.ry_delegate?.playerDurationDidChange(self)
    }
    
    func playerItemBufferLoadedTimeDidChange(_ playerItem: RYAVPlayerItem) {
//        self.ry_delegate?.playerBufferLoadedTimeDidChange(self)
    }
    
    func playerItemStatusDidChange(_ playerItem: RYAVPlayerItem) {
//        self.delegate
    }
    
    func playerItemPlaybackBufferEmpty(_ playerItem: RYAVPlayerItem) {
//        self.ry_delegate?.playerPlaybackBufferEmpty(self)
    }
    
    func playerItemPlaybackBufferFull(_ playerItem: RYAVPlayerItem) {
//        self.ry_delegate?.playerPlaybackBufferFull(self)
    }
    
    func playerItemDidLoadPresentationSize(_ playerItem: RYAVPlayerItem) {
//        self.ry_delegate?.playerDidLoadPresentationSize(self)
    }
    
    func playerItemDidPlayToEndTime(_ playerItem: RYAVPlayerItem) {
//        self.ry_delegate?.playerDidPlayToEndTime(self)
    }
    
    func playerCurrentTimeDidChange(_ player: RYAVPlayer) {
//        self.ry_delegate?.playerCurrentTimeDidChange(self)
    }
}
