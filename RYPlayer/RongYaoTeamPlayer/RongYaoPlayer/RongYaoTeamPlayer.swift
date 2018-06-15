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
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey Key: RongYaoTeamPlayerPropertyKey)
}
/// 播放器当前的状态
///
/// - unknown: 未播放任何资源时的状态
/// - readyToPlay: 资源准备就绪
/// - playing: 播放中
/// - paused:  暂停状态
/// - inactivity: 不活跃状态
public enum RongYaoTeamPlayerPlayStatus {
    case unknown
    case readyToPlay
    case playing
    case paused(reason: RongYaoTeamPlayerPausedReason)
    case inactivity(reason: RongYaoTeamPlayerInactivityReason)
}
/// 播放暂停的理由
///
/// - buffering: 正在缓冲
/// - pause:     被暂停
public enum RongYaoTeamPlayerPausedReason {
    case buffering
    case pause
}
/// 播放不活跃的原因
///
/// - playEnd:    播放完毕
/// - playFailed: 播放失败
public enum RongYaoTeamPlayerInactivityReason {
    case playEnd
    case playFailed
}
/// 缓冲的状态
///
/// - unknown: 未知, 可能还未播放
/// - empty:   缓冲区为空
/// - full:    缓冲区已满
public enum RongYaoTeamPlayerBufferStatus {
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
/// - ry_bufferStatus: 同 RongYaoTeamPlayer.ry_bufferStatus
/// - ry_presentationSize: 同 RongYaoTeamPlayer.ry_presentationSize
public enum RongYaoTeamPlayerPropertyKey {
    case ry_state
    case ry_duration
    case ry_currentTime
    case ry_bufferLoadedTime
    case ry_bufferStatus
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
        ry_avPlayer = otherAsset.ry_avPlayer
        ry_isOtherAsset = true
    }
}
public class RongYaoTeamPlayer: NSObject {
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    /// 播放资源
    /// - 使用URL进行初始化
    public var ry_asset: RongYaoTeamPlayerAsset? { didSet { ry_assetDidChange() } }
    
    /// player view
    public var ry_view: UIView = {
       let view = RongYaoTeamPlayerView.init(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    
    /// 资源播放的一些属性
    /// - 如: ry_assetProperties.duration
    /// - .....
    /// - 如: ry_assetProperties.currentTime
    public var ry_assetProperties: RongYaoTeamPlayerAssetProperties?
    
    /// 代理
    public weak var ry_delegate: RongYaoTeamPlayerDelegate?
    
    /// 播放状态
    public fileprivate(set) var ry_state: RongYaoTeamPlayerPlayStatus = .unknown { didSet { ry_stateDidChange() } }
    
    /// 是否自动播放
    /// - 当资源初始化完成后, 是否自动播放
    /// - 默认为 true
    public var ry_autoplay: Bool = true

    /// 资源初始化期间, 开发者进行的操作
    private var ry_operationOfInitializing: ()?

    /// 使播放
    public func ry_play() {
        // 播放失败
        if case RongYaoTeamPlayerPlayStatus.inactivity(reason: .playFailed) = ry_state {
            // 尝试重新播放
            ry_replay()
            return
        }
        
        // 播放中
        if case RongYaoTeamPlayerPlayStatus.playing = ry_state {
            return
        }
        
        // 状态未知
        if case RongYaoTeamPlayerPlayStatus.unknown = ry_state {
            // 记录操作
            ry_operationOfInitializing = self.ry_replay()
            return
        }

        ry_asset?.ry_avPlayer?.play()
        ry_state = .playing
        ry_operationOfInitializing = nil
    }
    
    /// 使暂停
    public func ry_pause() {
        _pause(.pause)
    }
    
    private func _pause(_ reason: RongYaoTeamPlayerPausedReason) {
        // 播放失败
        if case RongYaoTeamPlayerPlayStatus.inactivity(reason: .playFailed) = ry_state {
            return
        }
        
        switch ry_state {
        case .paused(reason: reason): return
        default: break
        }
        
        // 状态未知
        if case RongYaoTeamPlayerPlayStatus.unknown = ry_state {
            // 记录操作
            ry_operationOfInitializing = self.ry_pause()
            return
        }
        
        ry_asset?.ry_avPlayer?.pause()
        ry_state = .paused(reason: reason)
        ry_operationOfInitializing = nil
    }
    
    /// 使停止
    public func ry_stop() {
        ry_operationOfInitializing = nil
        ry_assetProperties = nil
        ry_asset = nil
        ry_state = .unknown
    }
    
    /// 使重新播放
    public func ry_replay() {
        guard let `ry_asset` = ry_asset else { return }
        // 播放失败
        if case RongYaoTeamPlayerPlayStatus.inactivity(reason: .playFailed) = ry_state {
            self.ry_asset = RongYaoTeamPlayerAsset.init(ry_asset.ry_URL, specifyStartTime: ry_asset.ry_specifyStartTime)
            return
        }
        ry_seekToTime(0) { (_, _) in }
    }
    
    /// 跳转到指定时间
    ///
    /// - Parameters:
    ///   - time:              将要跳转的时间
    ///   - completionHandler: 操作完成/失败 后的回调
    public func ry_seekToTime(_ time: TimeInterval, completionHandler: @escaping (_ player: RongYaoTeamPlayer, _ finished: Bool)->Void) {
        switch ry_state {
        case .unknown, .inactivity(reason: .playFailed):
            completionHandler(self, false)
            return
        default:
            break
        }
        
        guard let `ry_assetProperties` = ry_assetProperties else {
            completionHandler(self, false)
            return
        }
        
        if ( time > ry_assetProperties.ry_duration || time < 0 ) {
            completionHandler(self, false)
            return
        }
        
        if ( floor(ry_assetProperties.ry_currentTime) == floor(time) ) {
            completionHandler(self, true)
            return
        }
        
        ry_asset?.ry_playerItem?.cancelPendingSeeks()
        ry_asset?.ry_playerItem?.seek(to: CMTimeMakeWithSeconds(Float64.init(time), Int32(NSEC_PER_SEC)), completionHandler: { [weak self] (finished) in
            guard let `self` = self else { return }
            self.ry_play()
            completionHandler(self, finished)
        })
    }

    /// -----------------------------------------------------------------------
    /// 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线
    /// -----------------------------------------------------------------------
    /// 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看
    /// -----------------------------------------------------------------------
    
    fileprivate func ry_valueDidChangeForKey(_ key: RongYaoTeamPlayerPropertyKey) {
        ry_delegate?.player(self, valueDidChangeForKey: key)
    }
    
    /// -----------------------------------------------------------------------
    
    /// 播放器状态被改变
    private func ry_stateDidChange() {
        self.ry_valueDidChangeForKey(.ry_state)
        print("state: ", ry_state)
    }
    
    /// -----------------------------------------------------------------------

    private func ry_assetDidChange() {
        if ( ry_asset != nil ) {
            ry_needPlayNewAsset()
        }
        else {
            ry_needResetPlayer()
        }
    }
    
    private func ry_needPlayNewAsset() {
        ry_needResetPlayer()
        // 2. prepare
        // - 初始化AVPlayer
        // - 初始化完成后, 创建记录员
        ry_asset?.ry_initializingAVPlayer { [weak self] (asset) in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                guard let `avplayer` = asset.ry_avPlayer else {
                    self.ry_state = .inactivity(reason: .playFailed)
                    return
                }
                (self.ry_view as! RongYaoTeamPlayerView).avPlayer = avplayer
                // 3. obseve properties
                self.ry_assetProperties = RongYaoTeamPlayerAssetProperties.init(self.ry_asset!, delegate: self)
            }
        }
    }
    
    private func ry_needResetPlayer() {
        ry_state = .unknown
        ry_assetProperties = nil
    }
    
    /// -----------------------------------------------------------------------
    
    /// player item status
    fileprivate func ry_playerItemStatusDidChange(_ status: AVPlayerItemStatus) {
        switch status {
        case .unknown: break
        case .readyToPlay:
            self.ry_state = .readyToPlay
            if let `ry_operationOfInitializing` = ry_operationOfInitializing {
                ry_operationOfInitializing
            }
            else if ( self.ry_autoplay ) {
                ry_play()
            }
        case .failed:
            ry_state = .inactivity(reason: .playFailed)
        }
    }
    
    /// player item did play to end
    private func ry_playerItemDidPlayToEnd() {
        ry_state = .inactivity(reason: .playEnd)
    }

    /// -----------------------------------------------------------------------
    
    fileprivate func ry_bufferStatusDidChange(_ buffer: RongYaoTeamPlayerBufferStatus) {
        switch buffer {
        case .unknown: break
        case .empty:
            _pause(.buffering)
        case .full:
            // 如果已暂停, break
            if case RongYaoTeamPlayerPlayStatus.paused(reason: .pause) = ry_state {
                break
            }
            ry_play()
        }
        
        ry_valueDidChangeForKey(.ry_bufferStatus)
        print("bufferState: ", buffer)
    }
}

extension RongYaoTeamPlayer: RongYaoTeamPlayerAssetPropertiesDelegate {
    func properties(_ p: RongYaoTeamPlayerAssetProperties, durationDidChange duration: TimeInterval) {
        self.ry_valueDidChangeForKey(.ry_duration)
    }
    
    func properties(_ p: RongYaoTeamPlayerAssetProperties, currentTimeDidChange currentTime: TimeInterval) {
        self.ry_valueDidChangeForKey(.ry_currentTime)
    }
    
    func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferLoadedTimeDidChange bufferLoadedTime: TimeInterval) {
        self.ry_valueDidChangeForKey(.ry_bufferLoadedTime)
    }
    
    func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferStatusDidChange bufferStatus: RongYaoTeamPlayerBufferStatus) {
        self.ry_bufferStatusDidChange(bufferStatus)
    }
    
    func properties(_ p: RongYaoTeamPlayerAssetProperties, presentationSizeDidChange presentationSize: CGSize) {
        self.ry_valueDidChangeForKey(.ry_presentationSize)
    }
    
    func playerItemDidPlayToEnd(_ p: RongYaoTeamPlayerAssetProperties) {
        self.ry_playerItemDidPlayToEnd()
    }
    
    func properties(_ p: RongYaoTeamPlayerAssetProperties, playerItemStatusDidChange status: AVPlayerItemStatus) {
        self.ry_playerItemStatusDidChange(status)
    }
}

fileprivate protocol RongYaoTeamPlayerAssetPropertiesDelegate: NSObjectProtocol {
    func properties(_ p: RongYaoTeamPlayerAssetProperties, durationDidChange duration: TimeInterval)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, currentTimeDidChange currentTime: TimeInterval)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferLoadedTimeDidChange bufferLoadedTime: TimeInterval)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferStatusDidChange bufferStatus: RongYaoTeamPlayerBufferStatus)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, presentationSizeDidChange presentationSize: CGSize)

    func playerItemDidPlayToEnd(_ p: RongYaoTeamPlayerAssetProperties)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, playerItemStatusDidChange status: AVPlayerItemStatus)
}

/// 记录资源的一些信息
public class RongYaoTeamPlayerAssetProperties {
    
    /// 播放时长
    public private(set) var ry_duration: TimeInterval = 0 { didSet{ self.ry_delegate!.properties(self, durationDidChange: self.ry_duration) } }
    
    /// 当前时间
    public private(set) var ry_currentTime: TimeInterval = 0 { didSet{ self.ry_delegate!.properties(self, currentTimeDidChange: self.ry_currentTime) } }
    
    /// 已缓冲到的时间
    public private(set) var ry_bufferLoadedTime: TimeInterval = 0 { didSet{ self.ry_delegate!.properties(self, bufferLoadedTimeDidChange: ry_bufferLoadedTime) } }
    
    /// 缓冲状态
    public private(set) var ry_bufferStatus: RongYaoTeamPlayerBufferStatus = .unknown { didSet{ self.ry_delegate!.properties(self, bufferStatusDidChange: ry_bufferStatus) } }

    /// 视频宽高
    /// - 资源初始化未完成之前, 该值为 .zero
    public private(set) var ry_presentationSize: CGSize = CGSize.zero { didSet{ self.ry_delegate!.properties(self, presentationSizeDidChange: ry_presentationSize) } }
    
    
    
    
    
    
    
    
    
    /// -----------------------------------------------------------------------
    /// 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线
    /// -----------------------------------------------------------------------
    /// 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看
    /// -----------------------------------------------------------------------
    private weak var ry_delegate: RongYaoTeamPlayerAssetPropertiesDelegate?
    
    /// 当前 player item 的状态
    fileprivate var ry_playerItemStatus: AVPlayerItemStatus = .unknown { didSet{ self.ry_delegate!.properties(self, playerItemStatusDidChange: ry_playerItemStatus) } }

    fileprivate init(_ asset: RongYaoTeamPlayerAsset, delegate: RongYaoTeamPlayerAssetPropertiesDelegate) {
        ry_asset = asset
        ry_delegate = delegate
        ry_addTimeObserverOfPlayer(asset.ry_avPlayer)
        ry_addObserverOfPlayerItem(asset.ry_playerItem, observerCotainer: &ry_playerItemObservers)
    }
    
    deinit {
        ry_asset.ry_avPlayer?.pause()
        ry_removeTimeObserverOfPlayer(ry_asset.ry_avPlayer)
        ry_removeObserverOfPlayerItem(ry_asset.ry_playerItem, observerContainer: &ry_playerItemObservers)
    }
    
    fileprivate private(set) var ry_asset: RongYaoTeamPlayerAsset

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
            self.ry_playerItemStatus = playerItem.status
        }))
        
        observerCotainer.append(RYObserver.init(owner: playerItem, observeKey: "playbackBufferEmpty", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            if ( playerItem.isPlaybackBufferEmpty == false ) { return }
            if ( self.ry_bufferStatus == .empty ) { return }
            self.ry_bufferStatus = .empty
            self.ry_pollingPlaybackBuffer()
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
            
            self.ry_delegate!.playerItemDidPlayToEnd(self)
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
            self.ry_bufferStatus = .full
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
    
    
    
    
    /// -----------------------------------------------------------------------
    /// 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线 分割线
    /// -----------------------------------------------------------------------
    /// 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看 不好看
    /// -----------------------------------------------------------------------
    
    
    fileprivate enum RongYaoPlayerAssetState: Int {
        case unknown = 0, prepare, initialized
    }
    
    
    fileprivate var ry_avPlayer: AVPlayer? {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_player, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_player) as? AVPlayer
        }
    }
    fileprivate var ry_asset: AVURLAsset? { return self.ry_playerItem?.asset as? AVURLAsset }
    fileprivate var ry_playerItem: AVPlayerItem? { return self.ry_avPlayer?.currentItem }
    fileprivate var ry_state: RongYaoPlayerAssetState {
        set {
            objc_setAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_state, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            if ( ry_isOtherAsset == true ) { return .initialized }
            let b = objc_getAssociatedObject(self, &RongYaoTeamPlayerInitPlayerAssociatedKeys.kry_state)
            if ( b != nil ) { return b! as! RongYaoPlayerAssetState }
            return .unknown
        }
    }
    
    /// 初始化 AVPlayer
    /// - 将操作任务添加到队列中
    /// - 任务完成后, 回调 block
    fileprivate func ry_initializingAVPlayer(_ completionBlock: @escaping (_ asset: RongYaoTeamPlayerAsset)->Void) {
        if ( self.ry_state == .initialized ) {
            completionBlock(self)
            return
        }
        
        if ( ry_state == .prepare ) {
            return
        }
        
        ry_state = .prepare
        ry_addOperationToQueue { [weak self] in
            guard let `self` = self else {
                return
            }
            self.ry_state = .initialized
            completionBlock(self)
        }
    }
    
    /// - 用来初始化Player的队列
    /// - 由于创建耗时所以, 将初始化任务放到了这个队列中
    private static var SERIAL_QUEUE: OperationQueue?
    
    /// - 添加初始化任务到队列
    /// - 由于创建一个AVPlayer耗时, 因此将其放入子线程进行操作
    /// - 当队列为nil时, 这里进行了队列的初始化工作
    private func ry_addOperationToQueue(_ completionBlock: @escaping ()->Void) {

        if ( RongYaoTeamPlayerAsset.SERIAL_QUEUE == nil ) {
            /// 初始化队列
            RongYaoTeamPlayerAsset.SERIAL_QUEUE = OperationQueue.init()
            RongYaoTeamPlayerAsset.SERIAL_QUEUE?.name = "com.SJPlayer.serialQueue"
            RongYaoTeamPlayerAsset.SERIAL_QUEUE?.maxConcurrentOperationCount = 1
        }
        
        RongYaoTeamPlayerAsset.SERIAL_QUEUE?.addOperation { [weak self] in
            guard let `self` = self else {
                return
            }
            
            let asset = AVURLAsset.init(url: self.ry_URL)
            let item = AVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            let player = AVPlayer.init(playerItem: item)
            
            // retain
            self.ry_avPlayer = player
            completionBlock()
        }
    }
    
    private struct RongYaoTeamPlayerInitPlayerAssociatedKeys {
        static var kry_player = "kry_player"
        static var kry_state = "kry_state"
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

fileprivate class RongYaoTeamPlayerView: UIView {
    override class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    fileprivate var avPlayer: AVPlayer? { didSet{ avPlayerDidChange() } }
    
    fileprivate var videoGravity: AVLayerVideoGravity = AVLayerVideoGravity.resizeAspect
    
    private func avPlayerDidChange() {
        self.playerLayer.player = self.avPlayer
    }
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
}
