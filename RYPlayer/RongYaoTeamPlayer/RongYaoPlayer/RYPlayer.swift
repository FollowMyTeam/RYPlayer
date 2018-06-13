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
public enum RYPlayState {
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
    /// 也就是当设置`player.ry_URL`时, 将回调此方法
    ///
    /// - Parameters:
    ///   - player:             播放器
    ///   - URL:                播放地址
    /// - Returns:              Void
    func player(_ player: RYPlayer, prepareToPlay URL: URL?) -> Void
    
    /// 当前时间改变的回调
    func playerCurrentTimeDidChange(_ player: RYPlayer) -> Void
    
    /// 持续时间改变的回调
    func playerDurationDidChange(_ player: RYPlayer) -> Void
    
    /// 缓冲进度改变的回调
    func playerBufferLoadedTimeDidChange(_ player: RYPlayer) -> Void
    
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

    /// 播放地址
    @objc public dynamic var ry_URL: URL?

    /// 播放器视图
    public var ry_view: UIView?
    
    /// 播放报错时的error
    public var ry_error: Error?
    
    /// 播放状态
    public var ry_state: RYPlayState
    
    /// 代理
    public weak var ry_delegate: RYPlayerDelegate?
    
    private var ry_asset: AVURLAsset? { return self.ry_playerItem?.asset as? AVURLAsset }
    
    private var ry_playerItem: RYAVPlayerItem? { return self.ry_player?.ry_playerItem }
    
    private var ry_player: RYAVPlayer?
    
    public override init() {
        ry_state = .unknown
        super.init()
        ry_addKeyObservers()
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


public extension RYPlayer {
    /// 播放时长
    var ry_duration: TimeInterval? {
        return self.ry_playerItem?.ry_duration
    }
    
    /// 当前时间
    var ry_currentTime: TimeInterval? {
        return self.ry_playerItem?.ry_currentTime
    }
    
    /// 已缓冲到的时间
    var ry_bufferLoadedTime: TimeInterval? {
        return self.ry_playerItem?.ry_bufferLoadedTime
    }
}

/// 播放器的初始化
/// 用来初始化一个RYAVPlayer
/// 由于创建耗时, 这里将初始化放到了子线程中
private extension RYPlayer {
    
    struct RYPlayerInitPlayerAssociatedKeys {
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
            objc_setAssociatedObject(self, &RYPlayerInitPlayerAssociatedKeys.kry_initOperation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &RYPlayerInitPlayerAssociatedKeys.kry_initOperation) as? Operation
        }
    }

    /// 播放一个新的URL
    /// 当播放一个新的URL时, 将操作任务添加到队列中.
    /// 同时取消上一次可能存在的任务
    func ry_prepareToPlay(_ newURL: URL?) {
        
        // clean old avplayer
        ry_player = nil

        if ( ry_URL == nil ) {
            return
        }
        
        ry_delegate?.player(self, prepareToPlay: newURL)
        
        ry_cancelInitOperation()
        
        ry_addOperationToQueue()
    }
    
    /// 取消之前的操作并将操作对象置空
    /// 当操作对象未完成并且未进行并且未取消时, 将其取消
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
            
            // create asset
            let asset = AVURLAsset.init(url: self.ry_URL!)
            
            // create palyer item
            let item = RYAVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            item.ry_delegate = self
            
            // create avplayer
            let player = RYAVPlayer.init(playerItem: item)
            player.ry_delegate = self
            
            // set new av player
            self.ry_player = player
            
            // clean operation object
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
    func playerItemDurationDidChange(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerDurationDidChange(self)
    }
    
    func playerItemBufferLoadedTimeDidChange(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerBufferLoadedTimeDidChange(self)
    }
    
    func playerItemStatusDidChange(_ playerItem: RYAVPlayerItem) {
//        self.delegate
    }
    
    func playerItemPlaybackBufferEmpty(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerPlaybackBufferEmpty(self)
    }
    
    func playerItemPlaybackBufferFull(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerPlaybackBufferFull(self)
    }
    
    func playerItemDidLoadPresentationSize(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerDidLoadPresentationSize(self)
    }
    
    func playerItemDidPlayToEndTime(_ playerItem: RYAVPlayerItem) {
        self.ry_delegate?.playerDidPlayToEndTime(self)
    }
    
    func playerCurrentTimeDidChange(_ player: RYAVPlayer) {
        self.ry_delegate?.playerCurrentTimeDidChange(self)
    }
}
