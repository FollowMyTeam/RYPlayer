//
//  RongYaoTeamPlayer.swift
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
/// - paused:  暂停状态
/// - stopped: 停止状态
public enum RYPlayState {
    case unknown
    case prepare
    case playing
    case paused(reason: RongYaoTeamPlayerPausedReason)
    case stopped(reason: RongYaoTeamPlayerStoppedReason)
}
/// 播放暂停的理由
///
/// - buffering: 正在缓冲
/// - pause:     被暂停
public enum RongYaoTeamPlayerPausedReason {
    case buffering
    case pause
}
/// 播放停止的原因
///
/// - playEnd:    播放完毕
/// - playFailed: 播放失败
public enum RongYaoTeamPlayerStoppedReason {
    case playEnd
    case playFailed
}
/// 缓冲的状态
///
/// - unknown: 未知, 可能还未播放
/// - empty:   缓冲区为空
/// - full:    缓冲区已满
public enum RongYaoTeamPlayerBufferState {
    case unknown
    case empty
    case full
}
/// 播放器的代理
public protocol RongYaoTeamPlayerDelegate: NSObjectProtocol {
    /// 相应的属性, 当值改变时的回调
    ///
    /// - Parameters:
    ///   - player: 播放器
    ///   - valueDidChangeForKey: 相应的属性
    /// - Returns: Void
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey: RongYaoTeamPlayerPropertyKey) -> Void
}
/// 播放器的属性key
///
/// - ry_state: 同 RongYaoTeamPlayer.ry_state
/// - ry_duration: 同 RongYaoTeamPlayer.ry_duration
/// - ry_currentTime: 同 RongYaoTeamPlayer.ry_currentTime
/// - ry_bufferLoadedTime: 同 RongYaoTeamPlayer.ry_bufferLoadedTime
/// - ry_bufferState: 同 RongYaoTeamPlayer.ry_bufferState
/// - ry_presentationSize: 同 RongYaoTeamPlayer.ry_presentationSize
public enum RongYaoTeamPlayerPropertyKey {
    case ry_state
    case ry_duration
    case ry_currentTime
    case ry_bufferLoadedTime
    case ry_bufferState
    case ry_presentationSize
}

/// 播放器资源
/// - 记录URL
/// - 记录播放的开始时间
public class RongYaoTeamPlayerAsset {
    
    public private(set) var ry_URL: URL
    public private(set) var ry_specifyStartTime: TimeInterval = 0
    public private(set) var ry_isOtherAsset = false
    
    public init(_ playURL: URL, specifyStartTime: TimeInterval) {
        ry_specifyStartTime = specifyStartTime
        ry_URL = playURL
    }
    
    public convenience init(_ playURL: URL) {
        self.init(playURL, specifyStartTime: 0)
    }
    
    public init(_ otherAsset: RongYaoTeamPlayerAsset) {
        ry_URL = otherAsset.ry_URL
        ry_specifyStartTime = otherAsset.ry_specifyStartTime
        ry_player = otherAsset.ry_player
        ry_isOtherAsset = true
    }
    
    deinit {
        ry_cancelOperation()
    }
}


public class RongYaoTeamPlayer: RongYaoTeamPlayerAssetDelegate {
    /// 播放资源
    public var ry_asset: RongYaoTeamPlayerAsset? {
        didSet {
            if let `asset` = ry_asset { asset.ry_initializingPlayer(delegate: self) }
        }
    }
    
    /// 代理
    public weak var ry_delegate: RongYaoTeamPlayerDelegate?
    
    /// 播放状态
    public private(set) var ry_state: RYPlayState = .unknown {
        didSet {
            print("ry_state \(oldValue) \(ry_state)\n")
            valueDidChangeForKey(.ry_state, oldValue: oldValue)
        }
    }
    
    /// 播放时长
    public private(set) var ry_duration: TimeInterval = 0 {
        didSet {
            print("ry_duration \(oldValue) \(ry_duration)\n")
            valueDidChangeForKey(.ry_duration, oldValue: oldValue)
        }
    }
    
    /// 当前时间
    public private(set) var ry_currentTime: TimeInterval = 0 {
        didSet {
            print("ry_currentTime \(oldValue) \(ry_currentTime)\n")
            valueDidChangeForKey(.ry_currentTime, oldValue: oldValue)
        }
    }
    
    /// 已缓冲到的时间
    public private(set) var ry_bufferLoadedTime: TimeInterval = 0 {
        didSet {
            print("ry_bufferLoadedTime \(oldValue) \(ry_bufferLoadedTime)\n")
            valueDidChangeForKey(.ry_bufferLoadedTime, oldValue: oldValue)
        }
    }
    
    /// 缓冲状态
    public private(set) var ry_bufferState: RongYaoTeamPlayerBufferState = .unknown {
        didSet {
            print("ry_bufferState \(oldValue) \(ry_bufferState)\n")
            valueDidChangeForKey(.ry_bufferState, oldValue: oldValue)
        }
    }
    
    ///
    public private(set) var ry_presentationSize: CGSize = CGSize.zero {
        didSet {
            print("ry_presentationSize \(oldValue) \(ry_presentationSize)\n")
            valueDidChangeForKey(.ry_presentationSize, oldValue: oldValue)
        }
    }
    
    private func valueDidChangeForKey (_ key: RongYaoTeamPlayerPropertyKey, oldValue: Any) {
        self.ry_delegate?.player(self, valueDidChangeForKey: key)
        switch key {
        default:
            print("----dsfsd----")
        }
    }
    
    deinit {
        if let `asset` = self.ry_asset {
            ry_removeTimeObserverOfPlayer(asset.ry_player)
            ry_removeObserverOfPlayerItem(asset.ry_playerItem, observerContainer: &ry_playerItemObservers)
        }
    }
    
    private var ry_playerItemObservers = [RYObserver]()
    
    public func playerInitializedOfAsset(_ asset: RongYaoTeamPlayerAsset) {
        if ( asset.ry_initialized == false ) {
            return
        }
        
        ry_addObserverOfPlayerItem(asset.ry_playerItem!, observerCotainer: &ry_playerItemObservers)
        ry_addTimeObserverOfPlayer(asset.ry_player!)
    }
}



extension RongYaoTeamPlayer {
    /// - player item observers
    private func ry_addObserverOfPlayerItem(_ playerItem: AVPlayerItem?, observerCotainer: inout [RYObserver]) {
        guard let `playerItem` = playerItem else {
            return
        }
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "duration", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            
            self.ry_duration = CMTimeGetSeconds(playerItem.duration)
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "loadedTimeRanges", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            var time: TimeInterval = 0
            if ( playerItem.loadedTimeRanges.first == nil ) {
                time = 0
            }
            else {
                let range = playerItem.loadedTimeRanges.first!.timeRangeValue
                time = TimeInterval.init(CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration))
            }
            self.ry_bufferLoadedTime = time
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "status", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            //            self.ry_playerItemStatus = playerItem.status
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            self.ry_asset?.ry_player?.play()
            print(self)
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "playbackBufferEmpty", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            if ( playerItem.isPlaybackBufferEmpty == true ) {
                self.ry_bufferState = .empty
                self.ry_pollingPlaybackBuffer()
            }
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "presentationSize", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_presentationSize = playerItem.presentationSize
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, nota: NSNotification.Name.AVPlayerItemDidPlayToEndTime, exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            /// next next next next next next next next next next
            print(self)
        }))
    }
    
    private func ry_removeObserverOfPlayerItem(_ playerItem: AVPlayerItem?, observerContainer: inout [RYObserver]) {
        guard let `playerItem` = playerItem else {
            return
        }
        for kvo in observerContainer {
            kvo.remove(owner: playerItem)
        }
    }
    
    /// - 轮询缓冲, 查看是否可以继续播放
    private func ry_pollingPlaybackBuffer() {
        if ( ry_isWaitingPlaybackBuffer == true ) {
            return
        }
        
        ry_refreshBufferTimer = Timer.sj_timer(interval: 2, block: { [weak self] (timer) in
            guard let `self` = self else {
                timer.invalidate()
                return
            }
            
            let duration = self.ry_duration
            if ( duration == 0 ) {
                return
            }
            
            let pre_buffer = self.ry_maxPreTime;
            let currentBufferLoadedTime = self.ry_bufferLoadedTime
            if ( pre_buffer > currentBufferLoadedTime ) {
                return
            }
            
            timer.invalidate()
            ry_isWaitingPlaybackBuffer = false
            self.ry_bufferState = .full
            }, repeats: true)
        
        RunLoop.main.add(ry_refreshBufferTimer!, forMode: .commonModes)
        ry_refreshBufferTimer!.fireDate = Date.init(timeIntervalSinceNow: ry_refreshBufferTimer!.timeInterval)
    }
    
    /// - 最长准备时间(缓冲)可以播放
    /// - 单位秒
    private var ry_maxPreTime: TimeInterval {
        get {
            let max = self.ry_duration
            if ( max == 0 ) {
                return 0
            }
            let pre = self.ry_currentTime + 5
            return pre < max ? pre : max
        }
    }
    
    /// - 用于刷新当前的缓冲进度
    /// - 此timer将会每2秒刷新一次
    /// - 缓冲进度 > ry_maxPreTime, 代表可以继续播放
    private var ry_refreshBufferTimer: Timer? {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerBufferRefreshAssociatedKeys.kry_refreshBufferTimer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &RongYaoTeamPlayerBufferRefreshAssociatedKeys.kry_refreshBufferTimer) as? Timer
        }
    }
    
    /// - 是否正在等待缓冲
    private var ry_isWaitingPlaybackBuffer: Bool {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerBufferRefreshAssociatedKeys.kry_isWaitingPlaybackBuffer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let b = objc_getAssociatedObject(self, &RongYaoTeamPlayerBufferRefreshAssociatedKeys.kry_isWaitingPlaybackBuffer) as? Bool
            if ( b != nil ) { return b! }
            return false
        }
    }
    
    /// - player current timer observer
    private var ry_currentTimeObserver: Any? {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerBufferRefreshAssociatedKeys.kry_currentTimeObserver, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &RongYaoTeamPlayerBufferRefreshAssociatedKeys.kry_currentTimeObserver)
        }
    }

    private func ry_addTimeObserverOfPlayer(_ player: AVPlayer?) {
        guard let `player` = player else {
            return
        }
        
        ry_currentTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else {
                return
            }
            self.ry_currentTime = TimeInterval.init(CMTimeGetSeconds(time))
        })
    }
    
    private func ry_removeTimeObserverOfPlayer(_ player: AVPlayer?) {
        guard let `player` = player else {
            return
        }
        if ( ry_currentTimeObserver != nil ) { player.removeTimeObserver(ry_currentTimeObserver!) }
    }
    
    private struct RongYaoTeamPlayerBufferRefreshAssociatedKeys {
        static var kry_refreshBufferTimer = "kry_refreshBufferTimer"
        static var kry_isWaitingPlaybackBuffer = "kry_isWaitingPlaybackBuffer"
        static var kry_currentTimeObserver = "kry_currentTimeObserver"
    }
}



public protocol RongYaoTeamPlayerAssetDelegate {
    func playerInitializedOfAsset(_ asset: RongYaoTeamPlayerAsset)
}

fileprivate extension RongYaoTeamPlayerAsset {
    fileprivate var ry_player: AVPlayer? {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_player, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_player) as? AVPlayer
        }
    }
    
    fileprivate var ry_asset: AVURLAsset? { return self.ry_playerItem?.asset as? AVURLAsset }
    fileprivate var ry_playerItem: AVPlayerItem? { return self.ry_player?.currentItem }
    
    fileprivate var ry_initialized: Bool {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_initialized, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let b = objc_getAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_initialized)
            if ( b != nil ) { return b! as! Bool }
            return false
        }
    }
    
    /// - 初始化播放器
    /// - 将操作任务添加到队列中
    /// - 同时, 取消上一次可能存在的任务
    /// - 任务完成后, 将回调delegate
    fileprivate func ry_initializingPlayer(delegate: AnyObject & RongYaoTeamPlayerAssetDelegate) {
        if ( self.ry_initialized == true || ry_isOtherAsset == true ) {
            delegate.playerInitializedOfAsset(self)
            return
        }
        ry_cancelOperation()
        weak var weakDelegate = delegate
        ry_addOperationToQueue { [weak self] in
            guard let `self` = self else {
                return
            }
            weakDelegate?.playerInitializedOfAsset(self)
        }
    }
    
    /// - 用来初始化Player的队列
    /// - 由于创建耗时所以, 将初始化任务放到了这个队列中
    /// - 使用队列便于管理操作对象, 在某个时刻可以进行取消任务
    private static var SERIAL_QUEUE: OperationQueue?
    
    /// - 初始化的操作对象
    /// - `创建一个RYAVPlayer`的操作任务
    private var ry_initOperation: Operation? {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_initOperation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_initOperation) as? Operation
        }
    }
    
    /// - 取消之前的操作并将操作对象置空
    /// - 当操作对象`未完成`&`未进行`&`未取消`时, 将其取消
    /// - 最后操作对象置为nil
    private func ry_cancelOperation() {
        guard let `initOperation` = ry_initOperation else {
            return
        }
        
        if ( !initOperation.isFinished && !initOperation.isExecuting && !initOperation.isCancelled ) {
            initOperation.cancel()
        }
        
        self.ry_initOperation = nil
    }
    
    /// - 添加初始化任务到队列
    /// - 由于创建一个AVPlayer耗时, 因此将其放入子线程进行操作
    /// - 当队列为空时, 这里进行了队列的初始化工作
    private func ry_addOperationToQueue(_ completionBlock: @escaping ()->Void) {
        let operation = Operation.init()
        operation.completionBlock = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let asset = AVURLAsset.init(url: self.ry_URL)
            let item = AVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            let player = AVPlayer.init(playerItem: item)
            
            // retain
            self.ry_player = player
            // clean operation object
            self.ry_initOperation = nil
            self.ry_initialized = true
            completionBlock()
        }
        
        if ( RongYaoTeamPlayerAsset.SERIAL_QUEUE == nil ) {
            /// 初始化队列
            RongYaoTeamPlayerAsset.SERIAL_QUEUE = OperationQueue.init()
            RongYaoTeamPlayerAsset.SERIAL_QUEUE?.name = "com.SJPlayer.serialQueue"
            RongYaoTeamPlayerAsset.SERIAL_QUEUE?.maxConcurrentOperationCount = 1
        }
        
        RongYaoTeamPlayerAsset.SERIAL_QUEUE?.addOperation(operation)
        ry_initOperation = operation
    }
    
    private struct RongYaoTeamPlayerInitPlayerAssociatedKeys {
        static var kry_initOperation = "kry_initOperation"
        static var kry_player = "kry_player"
        static var kry_initialized = "kry_initialized"
    }
}

fileprivate extension Timer {
    
    class func sj_timer(interval: TimeInterval, block: (Timer)->Void, repeats: Bool) -> Timer {
        let timer = Timer.init(timeInterval: interval, target: self, selector: #selector(sj_exeBlock(timer:)), userInfo: block, repeats: repeats)
        return timer
    }
    
    @objc private class func sj_exeBlock(timer: Timer) -> Void {
        let block = timer.userInfo as? (Timer)->Void
        if ( block == nil ) {
            timer.invalidate()
        }
        else {
            block!(timer)
        }
    }
}
