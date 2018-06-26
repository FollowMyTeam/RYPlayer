//
//  RongYaoTeamPlayer.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - 播放器(base)

public class RongYaoTeamPlayer {
   
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
        view.removeFromSuperview()
    }
    
    public init() {
        registrar.delegate = self
        view = RongYaoTeamPlayerView.init(frame: .zero)
        view.backgroundColor = .black
    }
    
    /// 播放资源
    /// - 使用URL进行初始化
    public var asset: RongYaoTeamPlayerAsset? { didSet{ assetDidChange() } }
    
    /// 播放器视图
    /// - 呈现
    /// - 旋转
    public private(set) var view: RongYaoTeamPlayerView!
    
    /// 资源的一些属性
    /// - 如: 视频时长
    /// - .....
    /// - 如: 当前播放到的时间
    public private(set) var assetProperties: RongYaoTeamPlayerAssetProperties?
    
    /// 代理
    public var delegates: RongYaoMultidelegateManager<RongYaoTeamPlayerDelegate> = RongYaoMultidelegateManager()
    
    /// 播放状态
    public private(set) var status: Status = .unknown { didSet { stateDidChange() } }
    
    /// 是否静音
    public var mute: Bool = false {
        didSet {
            self.asset?.avPlayer?.isMuted = mute
        }
    }
    
    /// 速率, default is 1.0
    public var rate: Float {
        set{
            var _new = newValue; if ( _new < 0.1 ) { _new = 0.1 }
            
            if ( _rate == _new ) { return }
           
            _rate = _new
            
            if ( self.asset?.avPlayer == nil ) { return }
            
            if case Status.playing = status {
                self.asset?.avPlayer?.rate = _rate
            }
        }
        
        get{
            return _rate
        }
    }
    private var _rate: Float = 1.0
    
    /// 是否自动播放
    /// - 当资源初始化完成后, 是否自动播放
    /// - 默认为 true
    public var autoplay: Bool = true
    
    /// 关于后台播放视频, 引用自: https://juejin.im/post/5a38e1a0f265da4327185a26
    ///
    /// 当您想在后台播放视频时:
    /// 1. 前往 `TARGETS` -> `Capability` -> enable `Background Modes` -> select this mode `Audio, AirPlay, and Picture in Picture`
    /// 2. 需要设置 player.pauseWhenAppDidEnterBackground = false; (该值默认为 true, 即App进入后台默认暂停).
    ///
    /// - default is true.
    public var pauseWhenAppDidEnterBackground: Bool = true
    
    
    /// 资源初始化期间, 开发者进行的操作
    /// - 此属性如果有值, 将在资源初始化完成时调用, 调用完成后会置为nil
    private var operationOfInitializing: (()->())?
    
    /// 使播放
    public func play() {
        guard let `asset` = self.asset else { return }
        
        if case Status.inactivity(reason: .playEnd) = status {
            replay()
            return
        }
        
        // 播放失败
        if case Status.inactivity(reason: .playFailed) = status {
            // 尝试重新播放
            replay()
            return
        }
        
        // 播放中
        if case Status.playing = status {
            return
        }
        
        // 状态未知
        if case Status.unknown = status {
            // 记录操作, 待资源初始化完成后调用
            operationOfInitializing = self.play
            return
        }
        
        if ( rate != asset.avPlayer!.rate ) { asset.avPlayer?.rate = rate }
        else { asset.avPlayer?.play() }
        status = .playing
    }
    
    /// 使暂停
    public func pause() {
        pause(.pause)
    }
    
    private func pause(_ reason: PausedReason) {
        guard let `asset` = self.asset else { return }
        
        switch status {
        case .paused(reason: reason): return
        default: break
        }
        
        if case Status.inactivity(reason: .playEnd) = status {
            if case PausedReason.pause = reason {
                return
            }
        }
        
        // 播放失败
        if case Status.inactivity(reason: .playFailed) = status {
            return
        }
        
        // 状态未知
        if case Status.unknown = status {
            // 记录操作
            if case PausedReason.pause = reason {
                operationOfInitializing = self.pause
            }
            return
        }
        
        asset.avPlayer?.pause()
        status = .paused(reason: reason)
    }
    
    /// 使停止
    /// - 将会把`state`置为`unknown`
    /// - 清除相关资源
    /// - 由于相关资源已清除, 所以需开发者重新创建资源进行播放
    public func stop() {
        operationOfInitializing = nil
        if ( asset?.isOtherAsset == false ) { self.view.presentView.setAVPlayer(nil) }
        if ( assetProperties != nil ) { assetProperties = nil }
        if ( asset != nil ) { asset = nil }
        if case Status.unknown = status {
            return
        }
        status = .unknown
    }
    
    /// 使重新播放
    /// - 跳转到开头, 重新播放
    /// - 如果`state`状态为`playFailed`, 将会尝试重新初始化
    public func replay() {
        guard let `asset` = self.asset else { return }
        
        // 播放失败
        if case Status.inactivity(reason: .playFailed) = status {
            self.asset = RongYaoTeamPlayerAsset.init(asset.playURL, specifyStartTime: asset.specifyStartTime)
            return
        }
        
        seekToTime(0)
    }
    
    /// 跳转到指定时间
    ///
    /// - Parameters:
    ///   - time:              将要跳转的时间
    ///   - completionHandler: 操作完成/失败 后的回调
    public func seekToTime(_ time: TimeInterval, completionHandler: @escaping ((_ player: RongYaoTeamPlayer, _ finished: Bool)->Void) = {(_, _) in } ) {
        switch status {
        case .unknown, .inactivity(reason: .playFailed):
            completionHandler(self, false)
            return
        default:
            break
        }
        
        guard let `assetProperties` = assetProperties else {
            completionHandler(self, false)
            return
        }
        
        if ( time > assetProperties.duration || time < 0 ) {
            completionHandler(self, false)
            return
        }
        
        let current = floor(assetProperties.currentTime)
        let seek = floor(time)
        if case Status.inactivity(reason: .playEnd) = status {
            // .... nothing ....
        }
        else if ( current == seek ) {
            completionHandler(self, true)
            return
        }
        
        if case Status.paused(reason: .seeking) = status {
            asset?.playerItem?.cancelPendingSeeks()
        }
        else {
            pause(.seeking)
        }
        asset?.playerItem?.seek(to: CMTimeMakeWithSeconds(Float64.init(time), Int32(NSEC_PER_SEC)), completionHandler: { [weak self] (finished) in
            guard let `self` = self else { return }
            self.play()
            completionHandler(self, finished)
        })
    }
    
    
    
    
    
    fileprivate func valueDidChangeForKey(_ key: PropertyKey) {
        for delegate in delegates.all() {
            delegate.player(self, valueDidChangeForKey: key)
        }
    }
    
    /// -----------------------------------------------------------------------
    
    /// 播放器状态被改变
    private func stateDidChange() {
        self.valueDidChangeForKey(.state)
        print("state: ", status)
    }
    
    /// -----------------------------------------------------------------------
    
    private func assetDidChange() {
        if ( asset != nil ) {
            needPlayNewAsset()
        }
        else {
            needResetPlayer()
        }
    }
    
    private func needPlayNewAsset() {
        assetProperties = nil
        if case Status.unknown = status {}
        else { status = .unknown }
        
        // 2. prepare
        // - 初始化AVPlayer
        // - 初始化完成后, 创建记录员
        asset?.initializingAVPlayer { [weak self] (asset) in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                guard let `avplayer` = asset.avPlayer else {
                    self.status = .inactivity(reason: .playFailed)
                    return
                }
                self.view.presentView.setAVPlayer(avplayer)
                // 3. obseve properties
                self.assetProperties = RongYaoTeamPlayerAssetProperties.init(self.asset!, delegate: self)
            }
        }
    }
    
    private func needResetPlayer() {
        stop()
    }
    
    /// -----------------------------------------------------------------------
    
    /// player item status
    fileprivate func playerItemStatusDidChange(_ status: AVPlayerItemStatus) {
        switch status {
        case .unknown: break
        case .readyToPlay:
            self.status = .readyToPlay
            // update mute
            let mute = self.mute; self.mute = mute
            
            if let `operationOfInitializing` = operationOfInitializing {
                operationOfInitializing()
                self.operationOfInitializing = nil
            }
            else if ( autoplay ) {
                play()
            }
        case .failed:
            self.status = .inactivity(reason: .playFailed)
        }
    }
    
    /// player item did play to end
    private func playerItemDidPlayToEnd() {
        status = .inactivity(reason: .playEnd)
    }
    
    /// -----------------------------------------------------------------------
    
    fileprivate func bufferStatusDidChange(_ buffer: BufferStatus) {
        switch buffer {
        case .unknown: break
        case .empty:
            pause(.buffering)
        case .full:
            // 如果已暂停, break
            if case Status.paused(reason: .pause) = status {
                break
            }
            play()
        }
        
        valueDidChangeForKey(.bufferStatus)
        print("bufferState: ", buffer)
    }
    
    
    /// -----------------------------------------------------------------------
    
    fileprivate func currentTimeDidChange() {
        // 正在播放
        if case Status.playing = status {
            valueDidChangeForKey(.currentTime)
        }
    }
    
    /// -----------------------------------------------------------------------
    
    /// 一些通知记录员
    private var registrar: RongYaoTeamRegistrar = RongYaoTeamRegistrar.init()
}

/// 播放器的代理
public protocol RongYaoTeamPlayerDelegate: NSObjectProtocol {
    /// 相应的属性, 当值改变时的回调
    ///
    /// - Parameters:
    ///   - player: 播放器
    ///   - valueDidChangeForKey: 相应的属性
    /// - Returns: Void
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey key: RongYaoTeamPlayer.PropertyKey)
}
public extension RongYaoTeamPlayer {
    /// 播放器当前的状态
    ///
    /// - unknown:      未播放任何资源时的状态
    /// - readyToPlay:  准备就绪
    /// - playing:      播放中
    /// - paused:       暂停状态
    /// - inactivity:   不活跃状态
    enum Status {
        case unknown
        case readyToPlay
        case playing
        case paused(reason: PausedReason)
        case inactivity(reason: InactivityReason)
    }
    /// 播放暂停的理由
    ///
    /// - buffering: 正在缓冲
    /// - pause:     被暂停
    /// - seeking:   正在跳转(调用seekToTime:时)
    enum PausedReason {
        case buffering
        case pause
        case seeking
    }
    /// 播放不活跃的原因
    ///
    /// - playEnd:    播放完毕
    /// - playFailed: 播放失败
    enum InactivityReason {
        case playEnd
        case playFailed
    }
    /// 缓冲的状态
    ///
    /// - unknown: 未知, 可能还未播放
    /// - empty:   缓冲区为空
    /// - full:    缓冲区已满
    enum BufferStatus {
        case unknown
        case empty
        case full
    }
    /// 播放器的属性key
    ///
    /// - state:             同 player.assetProperties.state
    /// - duration:          同 player.assetProperties.duration
    /// - currentTime:       同 player.assetProperties.currentTime
    /// - bufferLoadedTime:  同 player.assetProperties.bufferLoadedTime
    /// - bufferStatus:      同 player.assetProperties.bufferStatus
    /// - presentationSize:  同 player.assetProperties.presentationSize
    enum PropertyKey {
        case state
        case duration
        case currentTime
        case bufferLoadedTime
        case bufferStatus
        case presentationSize
    }
}
extension RongYaoTeamPlayer: RongYaoTeamPlayerAssetPropertiesDelegate {
    fileprivate func properties(_ p: RongYaoTeamPlayerAssetProperties, durationDidChange duration: TimeInterval) {
        valueDidChangeForKey(.duration)
    }
    
    fileprivate func properties(_ p: RongYaoTeamPlayerAssetProperties, currentTimeDidChange currentTime: TimeInterval) {
        currentTimeDidChange()
    }
    
    fileprivate func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferLoadedTimeDidChange bufferLoadedTime: TimeInterval) {
        valueDidChangeForKey(.bufferLoadedTime)
    }
    
    fileprivate func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferStatusDidChange bufferStatus: BufferStatus) {
        bufferStatusDidChange(bufferStatus)
    }
    
    fileprivate func properties(_ p: RongYaoTeamPlayerAssetProperties, presentationSizeDidChange presentationSize: CGSize) {
        valueDidChangeForKey(.presentationSize)
    }
    
    fileprivate func playerItemDidPlayToEnd(_ p: RongYaoTeamPlayerAssetProperties) {
        playerItemDidPlayToEnd()
    }
    
    fileprivate func properties(_ p: RongYaoTeamPlayerAssetProperties, playerItemStatusDidChange status: AVPlayerItemStatus) {
        playerItemStatusDidChange(status)
    }
}

fileprivate protocol RongYaoTeamPlayerAssetPropertiesDelegate {
    func properties(_ p: RongYaoTeamPlayerAssetProperties, durationDidChange duration: TimeInterval)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, currentTimeDidChange currentTime: TimeInterval)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferLoadedTimeDidChange bufferLoadedTime: TimeInterval)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, bufferStatusDidChange bufferStatus: RongYaoTeamPlayer.BufferStatus)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, presentationSizeDidChange presentationSize: CGSize)

    func playerItemDidPlayToEnd(_ p: RongYaoTeamPlayerAssetProperties)
    func properties(_ p: RongYaoTeamPlayerAssetProperties, playerItemStatusDidChange status: AVPlayerItemStatus)
}


extension RongYaoTeamPlayer: RongYaoTeamRegistrarDelegate {
    fileprivate func appWillEnterForeground() {
        self.view.presentView.setAVPlayer(asset?.avPlayer)
    }
    
    fileprivate func appDidEnterBackground() {
        if ( pauseWhenAppDidEnterBackground ) {
            pause()
        }
        else {
            self.view.presentView.setAVPlayer(nil)
        }
    }
    
    fileprivate func oldDeviceUnavailable() {
        if case Status.playing = status {
            pause()
        }
        else if case Status.paused(reason: .seeking) = status {
            pause()
        }
    }
    
    fileprivate func audioSessionInterruption() {
        pause()
    }
}

/// 记录资源的一些信息
public class RongYaoTeamPlayerAssetProperties {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayerAssetProperties")
        #endif
        
        asset.avPlayer?.pause()
        removeTimeObserverOfPlayer(asset.avPlayer)
    }
    
    /// error
    public private(set) var error: Error?
    
    /// 播放时长
    public private(set) var duration: TimeInterval = 0 { didSet{ self.delegate.properties(self, durationDidChange: self.duration) } }
    
    /// 当前时间
    public private(set) var currentTime: TimeInterval = 0 { didSet{ self.delegate.properties(self, currentTimeDidChange: self.currentTime) } }
    
    /// 已缓冲到的时间
    public private(set) var bufferLoadedTime: TimeInterval = 0 { didSet{ self.delegate.properties(self, bufferLoadedTimeDidChange: bufferLoadedTime) } }
    
    /// 缓冲状态
    public private(set) var bufferStatus: RongYaoTeamPlayer.BufferStatus = .unknown { didSet{ self.delegate.properties(self, bufferStatusDidChange: bufferStatus) } }

    /// 视频宽高
    /// - 资源初始化未完成之前, 该值为 .zero
    public private(set) var presentationSize: CGSize = CGSize.zero { didSet{ self.delegate.properties(self, presentationSizeDidChange: presentationSize) } }
    
    
    
    
    
    
    private weak var delegate: (AnyObject & RongYaoTeamPlayerAssetPropertiesDelegate)!
    
    /// 当前 player item 的状态
    fileprivate var playerItemStatus: AVPlayerItemStatus = .unknown { didSet{ self.delegate.properties(self, playerItemStatusDidChange: playerItemStatus) } }

    fileprivate init(_ asset: RongYaoTeamPlayerAsset, delegate: AnyObject & RongYaoTeamPlayerAssetPropertiesDelegate) {
        self.asset = asset
        self.delegate = delegate
        addTimeObserverOfPlayer(asset.avPlayer)
        addObserverOfPlayerItem(asset.playerItem, observerCotainer: &playerItemObservers)
    }
    
    fileprivate private(set) var asset: RongYaoTeamPlayerAsset
    
    private var playerItemObservers = [RongYaoObserver]()
    private var sought: Bool = false
    
    /// - player item observers
    private func addObserverOfPlayerItem(_ playerItem: AVPlayerItem?, observerCotainer: inout [RongYaoObserver]) {
        guard let `playerItem` = playerItem else {
            return
        }
        
        observerCotainer.append(RongYaoObserver.init(owner: playerItem, observeKey: "duration", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }

            self.duration = CMTimeGetSeconds(playerItem.duration)
        }))
        
        observerCotainer.append(RongYaoObserver.init(owner: playerItem, observeKey: "loadedTimeRanges", exeBlock: { [weak self] (helper) in
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
            self.bufferLoadedTime = time
        }))
        
        observerCotainer.append(RongYaoObserver.init(owner: playerItem, observeKey: "status", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            if ( playerItem.status == .readyToPlay && self.asset.specifyStartTime != 0 && self.sought == false ) {
                self.asset.playerItem?.seek(to: CMTimeMakeWithSeconds(self.asset.specifyStartTime, Int32(NSEC_PER_SEC)), completionHandler: { [weak self] (_) in
                    guard let `self` = self else { return }
                    self.sought = true
                    self.playerItemStatus = playerItem.status
                })
            }
            else {            
                self.playerItemStatus = playerItem.status
            }
            
            if ( playerItem.status == .failed ) { self.error = playerItem.error }
        }))
        
        observerCotainer.append(RongYaoObserver.init(owner: playerItem, observeKey: "playbackBufferEmpty", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            if ( playerItem.isPlaybackBufferEmpty == false ) { return }
            if ( self.bufferStatus == .empty ) { return }
            if ( floor(self.currentTime) == floor(self.duration) ) { return }
            self.bufferStatus = .empty
            self.pollingPlaybackBuffer()
        }))
        
        observerCotainer.append(RongYaoObserver.init(owner: playerItem, observeKey: "presentationSize", exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            
            self.presentationSize = playerItem.presentationSize
        }))
        
        observerCotainer.append(RongYaoObserver.init(owner: playerItem, nota: NSNotification.Name.AVPlayerItemDidPlayToEndTime, exeBlock: { [weak self] (helper) in
            guard let `self` = self else {
                return
            }
            
            self.delegate.playerItemDidPlayToEnd(self)
        }))
    }
    
    /// - 轮询缓冲, 查看是否可以继续播放
    private func pollingPlaybackBuffer() {
        if ( isWaitingPlaybackBuffer == true ) {
            return
        }
        
        refreshBufferTimer = Timer.sj_timer(interval: 2, block: { [weak self] (timer) in
            guard let `self` = self else {
                timer.invalidate()
                return
            }
            
            let duration = self.duration
            if ( duration == 0 ) {
                return
            }
            
            let pre_buffer = self.maxPreTime;
            let currentBufferLoadedTime = self.bufferLoadedTime
            if ( pre_buffer > currentBufferLoadedTime ) {
                return
            }
            
            timer.invalidate()
            isWaitingPlaybackBuffer = false
            self.bufferStatus = .full
            }, repeats: true)
        
        RunLoop.main.add(refreshBufferTimer!, forMode: .commonModes)
        refreshBufferTimer!.fireDate = Date.init(timeIntervalSinceNow: refreshBufferTimer!.timeInterval)
    }
    
    /// - 最长准备时间(缓冲)可以播放
    /// - 单位秒
    private var maxPreTime: TimeInterval {
        get {
            let max = self.duration
            if ( max == 0 ) {
                return 0
            }
            let pre = self.currentTime + 5
            return pre < max ? pre : max
        }
    }
    
    /// - 用于刷新当前的缓冲进度
    /// - 此timer将会每2秒刷新一次
    /// - 缓冲进度 > maxPreTime, 代表可以继续播放
    private var refreshBufferTimer: Timer?
    
    /// - 是否正在等待缓冲
    private var isWaitingPlaybackBuffer: Bool = false
    
    /// - player current timer observer
    private var currentTimeObserver: Any?
    
    private func addTimeObserverOfPlayer(_ player: AVPlayer?) {
        guard let `player` = player else {
            return
        }
        
        currentTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else {
                return
            }
            
            self.currentTime = TimeInterval.init(CMTimeGetSeconds(time))
        })
    }
    
    private func removeTimeObserverOfPlayer(_ player: AVPlayer?) {
        guard let `player` = player else {
            return
        }
        
        if ( currentTimeObserver != nil ) {
            player.removeTimeObserver(currentTimeObserver!)
            currentTimeObserver = nil
        }
    }
}

// MARK: - 资源 - 初始化AVPlayer
fileprivate extension RongYaoTeamPlayerAsset {
    
    var avPlayer: AVPlayer? {
        set {
            objc_setAssociatedObject(self, &InitPlayerAssociatedKeys.kplayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            if ( self.isOtherAsset ) { return self.otherAsset?.avPlayer }
            return objc_getAssociatedObject(self, &InitPlayerAssociatedKeys.kplayer) as? AVPlayer
        }
    }
    
    var asset: AVURLAsset? { return self.playerItem?.asset as? AVURLAsset }
    var playerItem: AVPlayerItem? { return self.avPlayer?.currentItem }

    /// 初始化 AVPlayer
    /// - 将操作任务添加到队列中
    /// - 任务完成后, 回调 block
    func initializingAVPlayer(_ completionBlock: @escaping (_ asset: RongYaoTeamPlayerAsset)->Void) {
        if ( self.state == .initialized ) { completionBlock(self); return }
        if ( state == .prepare ) { return }
        
        state = .prepare
        addOperationToQueue { [weak self] in
            guard let `self` = self else { return }
            self.state = .initialized
            completionBlock(self)
        }
    }
    

    /// - 用来初始化Player的队列
    /// - 由于创建耗时所以, 将初始化任务放到了这个队列中
    private static var SERIAL_QUEUE: OperationQueue?
    
    /// - 添加初始化任务到队列
    /// - 由于创建一个AVPlayer耗时, 因此将其放入子线程进行操作
    /// - 当队列为nil时, 这里进行了队列的初始化工作
    private func addOperationToQueue(_ completionBlock: @escaping ()->Void) {
        
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
            
            let asset = AVURLAsset.init(url: self.playURL)
            let item = AVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            let player = AVPlayer.init(playerItem: item)
            
            // retain
            self.avPlayer = player
            completionBlock()
        }
    }
    
    private enum RongYaoPlayerAssetState: Int {
        case unknown, prepare, initialized
    }
    
    private var state: RongYaoPlayerAssetState {
        set{
            objc_setAssociatedObject(self, &InitPlayerAssociatedKeys.kstate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get{
            if ( isOtherAsset == true ) { return .initialized }
            let b = objc_getAssociatedObject(self, &InitPlayerAssociatedKeys.kstate)
            if ( b != nil ) { return b! as! RongYaoPlayerAssetState }
            return .unknown
        }
    }
    
    private struct InitPlayerAssociatedKeys {
        static var kplayer = "kplayer"
        static var kstate = "kstate"
    }
}

fileprivate protocol RongYaoTeamRegistrarDelegate {
    func appWillEnterForeground()
    func appDidEnterBackground()
    func oldDeviceUnavailable()
    func audioSessionInterruption()
}

fileprivate class RongYaoTeamRegistrar {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        installNotifiactions()
    }
    
    fileprivate weak var delegate: (AnyObject & RongYaoTeamRegistrarDelegate)?
    
    private func installNotifiactions(){
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChange(_:)), name: .AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption(_:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }
    
    @objc func appWillEnterBackground() {
        self.delegate?.appWillEnterForeground()
    }
    
    @objc func appDidEnterBackground() {
        self.delegate?.appDidEnterBackground()
    }
    
    @objc func audioSessionRouteChange(_ notifi: Notification) {
        DispatchQueue.main.async { [weak self] in
            let info = notifi.userInfo!
            let reason = info[AVAudioSessionRouteChangeReasonKey] as! AVAudioSessionRouteChangeReason
            switch reason {
            case .oldDeviceUnavailable:
                self?.delegate?.oldDeviceUnavailable()
            default: break
            }
        }
    }
    
    @objc func audioSessionInterruption(_ notifi: Notification) {
        let info = notifi.userInfo!
        let type = info[AVAudioSessionInterruptionTypeKey] as! NSNumber
        if ( type.intValue == AVAudioSessionInterruptionType.began.rawValue ) {
            self.delegate?.audioSessionInterruption()
        }
    }
}
