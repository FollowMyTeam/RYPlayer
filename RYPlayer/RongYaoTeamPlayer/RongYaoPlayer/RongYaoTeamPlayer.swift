//
//  RongYaoTeamPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

/// 播放器的代理
public protocol RongYaoTeamPlayerDelegate: NSObjectProtocol {
    /// 相应的属性, 当值改变时的回调
    ///
    /// - Parameters:
    ///   - player: 播放器
    ///   - valueDidChangeForKey: 相应的属性
    /// - Returns: Void
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey Key: RongYaoTeamPlayerPropertyKey) -> Void
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
/// - playFailed: 操作失败
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
/// 使用两个参数进行初始化分别如下:
/// - URL
/// - 播放的开始时间
public class RongYaoTeamPlayerAsset {
    
    public private(set) var ry_URL: URL
    public private(set) var ry_specifyStartTime: TimeInterval = 0
    public private(set) var ry_isOtherAsset = false
    
    /// 创建一个Asset
    ///
    /// - Parameters:
    ///   - playURL: 播放的URL(本地/远程)
    ///   - specifyStartTime: 从指定时间开始播放, 默认为0
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


public class RongYaoTeamPlayer: NSObject {
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    /// 播放资源
    public var ry_asset: RongYaoTeamPlayerAsset? { didSet { ry_assetDidChange() } }
    
    /// 代理
    public weak var ry_delegate: RongYaoTeamPlayerDelegate?
    
    /// 播放状态
    public fileprivate(set) var ry_state: RYPlayState = .unknown { didSet { ry_valueDidChangeForKey(.ry_state) } }
    
    /// 当前 player item 的状态
    fileprivate var ry_playerItemStatus: AVPlayerItemStatus {
        if ( ry_assetProperty == nil ) { return .unknown }
        return ry_assetProperty!.ry_playerItemStatus
    }

    /// 是否自动播放
    /// - 当资源初始化完成后, 是否自动播放
    /// - 默认为 true
    public var ry_autoplay: Bool = true
    
    /// 资源的一些属性属性
    /// - 如: duration
    /// - 如: currentTime
    public var ry_assetProperty: RongYaoTeamPlayerAssetProperty?

    fileprivate func ry_valueDidChangeForKey (_ key: RongYaoTeamPlayerPropertyKey) {
        ry_delegate?.player(self, valueDidChangeForKey: key)
//        switch key {
//        default:
//            print("----dsfsd----")
//        }
    }
    
    private func ry_assetDidChange() {
        // 1. reset
        ry_resetPropertys()
        // 2. prepare
        ry_preparePlayAsset()
    }
    
    
    /// 重置播放所有相关的属性
    private func ry_resetPropertys() {
        ry_state = .unknown
        ry_assetProperty = nil
    }
    
    /// 准备播放一个Asset
    /// - 初始化AVPlayer
    /// - 当初始化完成后, 在主线程回调 ry_initializedAsset()
    private func ry_preparePlayAsset() {
        guard let `ry_asset` = ry_asset else { return }
        ry_asset.ry_initializingPlayer { [weak self] (asset) in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                self.ry_initializedAsset()
            }
        }
    }
    
    /// 资源初始化完成
    private func ry_initializedAsset() {
        self.ry_assetProperty = RongYaoTeamPlayerAssetProperty.init(self.ry_asset!, self)
    }
    
    /// 处理 AVPlayerItem 状态变更
    fileprivate func ry_playerItemStatusDidChange() {
        switch self.ry_playerItemStatus {
        case .unknown: break
        case .readyToPlay:
            self.ry_asset?.ry_player?.play()
        case .failed:
            self.ry_state = .stopped(reason: .playFailed)
        }
    }
    
    /// 使播放
    ///
    /// - Returns: 当异常状态时, 将有可能操作失败. 即返回 false
    public func play() -> Bool {
        return true
    }
    
    /// 使暂停
    ///
    /// - Returns: 当异常状态时, 将有可能操作失败. 即返回 false
    public func pause() -> Bool {
        return true
    }
    
    /// 使停止
    ///
    /// - Returns: 当异常状态时, 将有可能操作失败. 即返回 false
    public func stop() -> Bool {
        return true
    }
    
    /// 使重新播放
    ///
    /// - Returns: 当异常状态时, 将有可能操作失败. 即返回 false
    public func replay() -> Bool {
        return true
    }
    
    public func seekToTime(_ time: TimeInterval, completionHandler: @escaping (_ player: RongYaoTeamPlayer, _ finished: Bool)->Void) {
        guard let `ry_assetProperty` = ry_assetProperty else {
            completionHandler(self, false)
            return
        }
        
        if ( ry_assetProperty.ry_playerItemStatus.rawValue != AVPlayerItemStatus.readyToPlay.rawValue ) {
            completionHandler(self, false)
            return
        }
        
        if ( time > ry_assetProperty.ry_duration || time < 0 ) {
            completionHandler(self, false)
            return
        }
        
        if ( floor(ry_assetProperty.ry_currentTime) == floor(time) ) {
            completionHandler(self, true)
            return
        }

        self.ry_asset?.ry_playerItem?.cancelPendingSeeks()
        self.ry_asset?.ry_playerItem?.seek(to: CMTimeMakeWithSeconds(Float64.init(time), Int32(NSEC_PER_SEC)), completionHandler: { [weak self] (finished) in
            guard let `self` = self else { return }
            completionHandler(self, finished)
        })
    }
}

/// 记录资源的一些信息
/// - 负责观察 playerItem 属性值的改变
///     - duration
///     - loadedTimeRanges
///     - status
///     - playbackBufferEmpty
///     - presentationSize
///     - AVPlayerItemDidPlayToEndTime
/// - 负责观察 player 当前播放时间的改变
/// - 负责观察 缓冲的状态
/// - 负责监听 视频播放完毕
public class RongYaoTeamPlayerAssetProperty {
    
    /// 播放时长
    public fileprivate(set) var ry_duration: TimeInterval = 0
    
    /// 当前时间
    public fileprivate(set) var ry_currentTime: TimeInterval = 0
    
    /// 已缓冲到的时间
    public fileprivate(set) var ry_bufferLoadedTime: TimeInterval = 0
    
    /// 缓冲状态
    public fileprivate(set) var ry_bufferState: RongYaoTeamPlayerBufferState = .unknown
    
    /// 视频宽高
    /// - 资源初始化未完成之前, 该值为 .zero
    public fileprivate(set) var ry_presentationSize: CGSize = CGSize.zero
    
    init(_ asset: RongYaoTeamPlayerAsset, _ player: RongYaoTeamPlayer) {
        ry_asset = asset
        ry_player = player
        
        ry_addTimeObserverOfPlayer(asset.ry_player)
        ry_addObserverOfPlayerItem(asset.ry_playerItem, observerCotainer: &ry_playerItemObservers)
    }
    
    deinit {
        ry_removeTimeObserverOfPlayer(ry_asset.ry_player)
        ry_removeObserverOfPlayerItem(ry_asset.ry_playerItem, observerContainer: &ry_playerItemObservers)
    }
    
    fileprivate private(set) var ry_asset: RongYaoTeamPlayerAsset
    fileprivate private(set) weak var ry_player: RongYaoTeamPlayer?
    
    /// 当前 player item 的状态
    fileprivate var ry_playerItemStatus: AVPlayerItemStatus = .unknown

    /// 存放 player item 的属性观察者
    private var ry_playerItemObservers = [RYObserver]()
    
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
            self.ry_player?.ry_valueDidChangeForKey(.ry_duration)
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
            self.ry_player?.ry_valueDidChangeForKey(.ry_bufferLoadedTime)
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "status", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            self.ry_playerItemStatus = playerItem.status
            self.ry_player?.ry_playerItemStatusDidChange()
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "playbackBufferEmpty", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            
            if ( playerItem.isPlaybackBufferEmpty == true ) {
                self.ry_bufferState = .empty
                self.ry_pollingPlaybackBuffer()
                self.ry_player?.ry_valueDidChangeForKey(.ry_bufferState)
            }
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "presentationSize", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            
            self.ry_presentationSize = playerItem.presentationSize
            self.ry_player?.ry_valueDidChangeForKey(.ry_presentationSize)
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
            self.ry_player?.ry_valueDidChangeForKey(.ry_bufferState)
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
    private var ry_refreshBufferTimer: Timer?
    
    /// - 是否正在等待缓冲
    private var ry_isWaitingPlaybackBuffer: Bool = false
    
    /// - player current timer observer
    private var ry_currentTimeObserver: Any?
    
    private func ry_addTimeObserverOfPlayer(_ player: AVPlayer?) {
        guard let `player` = player else {
            return
        }
        
        ry_currentTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else {
                return
            }
            
            self.ry_currentTime = TimeInterval.init(CMTimeGetSeconds(time))
            self.ry_player?.ry_valueDidChangeForKey(.ry_currentTime)
        })
    }
    
    private func ry_removeTimeObserverOfPlayer(_ player: AVPlayer?) {
        guard let `player` = player else {
            return
        }
        
        if ( ry_currentTimeObserver != nil ) {
            player.removeTimeObserver(ry_currentTimeObserver!)
            ry_currentTimeObserver = nil
        }
    }
}

// MARK: - 资源 - 初始化AVPlayer
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
    fileprivate func ry_initializingPlayer(_ completionBlock: @escaping (_ asset: RongYaoTeamPlayerAsset)->Void) {
        if ( self.ry_initialized == true || ry_isOtherAsset == true ) {
            completionBlock(self)
            return
        }
        
        ry_cancelOperation()
        ry_addOperationToQueue { [weak self] in
            guard let `self` = self else {
                return
            }
            completionBlock(self)
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
