//
//  RongYaoTeamPlayerView.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/19.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

/// `播放器视图`方向
///
/// - portrait:       竖屏
/// - landscapeLeft:  全屏, Home键在右侧
/// - landscapeRight: 全屏, Home键在左侧
public enum RongYaoTeamViewOrientation: UInt {
    case portrait = 0
    case landscapeLeft = 1
    case landscapeRight = 2
}

/// `播放器视图`自动旋转支持的方向
public struct RongYaoTeamViewAutorotationSupportedOrientation: OptionSet {
    
    /// 是否支持全屏
    public static var portrait: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 0) }
    
    /// 是否支持全屏, Home键在右侧
    public static var landscapeLeft: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 1) }
    
    /// 是否支持全屏, Home键在左侧
    public static var landscapeRight: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 2) }
    
    /// 是否支持全部方向
    public static var all: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue | RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue | RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue) }
    
    /// init
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// value
    public var rawValue: UInt
}

/// `播放器视图`自带的手势类型
///
/// - singleTap: 单击
/// - doubleTap: 双击
/// - pan:       pan
/// - pinch:     捏合
public enum RongYaoTeamPlayerViewGestureType {
    case singleTap
    case doubleTap
    case pan
    case pinch
}

/// `播放器视图`默认支持的手势类型
public struct RongYaoTeamPlayerViewSupportedGestureTypes: OptionSet {
    
    /// 没有任何默认手势
    public static var none: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 0) }
    
    /// 是否支持单击手势
    public static var singleTap: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 0) }
    
    /// 是否支持双击手势
    public static var doubleTap: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 1) }
    
    /// 是否支持pan手势
    public static var pan: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 2) }
    
    /// 是否支持捏合手势
    public static var pinch: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 3) }
    
    /// 是否支持全部手势
    public static var all: RongYaoTeamPlayerViewSupportedGestureTypes {  return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: RongYaoTeamPlayerViewSupportedGestureTypes.singleTap.rawValue | RongYaoTeamPlayerViewSupportedGestureTypes.doubleTap.rawValue | RongYaoTeamPlayerViewSupportedGestureTypes.pan.rawValue | RongYaoTeamPlayerViewSupportedGestureTypes.pinch.rawValue ) }
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public var rawValue: UInt
}


/// 播放器视图
/// - 呈现视频
/// - 视图旋转
/// - 手势控制
///     - 单击
///     - 双击
///     - 快进/音量/声音
///     - 捏合
public class RongYaoTeamPlayerView: UIView {

    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentView)
        rotationManager = RongYaoTeamViewRotationManager.init(target: self.presentView, superview: self)
        rotationManager.reviser = self
        presentView.backgroundColor = UIColor.black
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if ( self.presentView.frame.isEmpty ) {
            presentView.frame = self.bounds
        }
    }
    
    /// 旋转管理
    /// - 手动旋转到指定方向
    /// - 设置自动旋转支持的方向
    /// - 设置旋转动画持续时间
    /// - 是否禁止自动旋转
    public private(set) var rotationManager: RongYaoTeamViewRotationManager!

    public var avVideoGravity: AVLayerVideoGravity {
        get{ return self.presentView.avVideoGravity }
        set{ self.presentView.avVideoGravity = newValue }
    }
    
    public func setAVPlayer(_ avPlayer: AVPlayer?) { self.presentView.setAVPlayer(avPlayer) }
    
    private private(set) var presentView: RongYaoTeamPlayerPresentView = RongYaoTeamPlayerPresentView.init(frame: .zero)
}

public protocol RongYaoTeamViewRotationManagerDelegate {
    /// 视图将要旋转时的回调
    func rotationManager(_ mgr: RongYaoTeamViewRotationManager, willRotateView isFullscreen: Bool)
    
    /// 视图旋转后的回调
    func rotationManager(_ mgr: RongYaoTeamViewRotationManager, didRotateView isFullscreen: Bool)
}

/// 旋转管理
/// - 自动旋转
/// - 旋转到指定方向
public class RongYaoTeamViewRotationManager {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamViewRotationManager")
        #endif
        self.blackView.removeFromSuperview()
        self.removeDeviceOrientationObserver()
    }
    
    public init(target: UIView, superview: UIView ) {
        self.target = target
        self.superview = superview
        self.observeDeviceOrientation()
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamViewRotationManagerDelegate)?

    /// 是否禁止自动旋转
    /// - 默认为 false
    /// - 只禁止自动旋转, 当调用 rotate 等方法还是可以旋转的
    public var disableAutorotation: Bool = false
    
    /// 自动旋转时, 所支持的方法
    /// - 默认为 .all
    public var autorotationSupportedOrientation: RongYaoTeamViewAutorotationSupportedOrientation = RongYaoTeamViewAutorotationSupportedOrientation.all
    
    /// 当前的方向
    public var currentOrientation: RongYaoTeamViewOrientation { return orientation }
    
    /// 动画持续的时间
    /// - 默认是 0.4
    public var duration: TimeInterval = 0.4

    /// 是否全屏
    public var isFullscreen: Bool { return ( orientation == .landscapeRight || orientation == .landscapeLeft ) }
    
    /// 旋转
    /// - Animated
    public func rotate() {
        /// 如果是全屏状态 并且 支持 Portrait
        if ( self.isFullscreen && isSupportedPortrait ) {
            self.rotate(.portrait, animated: true)
            
            return
        }
        
        /// 不是全屏或者不支持竖屏
        /// 就是要全屏
        /// 查看当前方向是否与设备方向一致
        /// 如果不一致, 当前设备朝哪个方向, 就旋转到那个方向
        if ( isCurrentOrientationAsDeviceOrientation == false ) {
            switch rec_deviceOrientation {
            case .landscapeLeft:
                if ( self.isSupportedLandscapeLeft ) {
                    self.rotate(.landscapeLeft, animated: true)
                }
            case .landscapeRight:
                if ( self.isSupportedLandscapeRight ) {
                    self.rotate(.landscapeRight, animated: true)
                }
            default: break
            }
            
            return
        }
        
        /// 如果方向一致, 就旋转到相反的方向
        switch rec_deviceOrientation {
        case .landscapeLeft:
            if ( self.isSupportedLandscapeRight ) {
                self.rotate(.landscapeRight, animated: true)
            }
        case .landscapeRight:
            if ( self.isSupportedLandscapeLeft ) {
                self.rotate(.landscapeLeft, animated: true)
            }
        default: break
        }
    }
    
    /// 旋转视图
    public fileprivate(set) var target: UIView
    
    /// 旋转视图的父视图
    public fileprivate(set) weak var superview: UIView?
    
    /// 转回小屏时, 需进行修正
    public var reviser: (AnyObject & RongYaoTeamViewRotationManagerReviser)?
    
    
// MARK: Private
    
    /// 记录的设备方向
    /// - 只记录三种设备方向 `.portrait, .landscapeLeft, .landscapeRight`
    private var rec_deviceOrientation: UIDeviceOrientation = .portrait
    
    /// - Any value of `RongYaoTeamViewOrientation`
    private var orientation: RongYaoTeamViewOrientation = .portrait
    
    /// 转换过的坐标
    private var con_portraitRect: CGRect = .zero
    
    /// 全屏时的背景视图
    private var blackView: UIView = {
        let blackView = UIView.init()
        blackView.backgroundColor = UIColor.black
        return blackView
    }()
    
    /// 旋转到指定方向
    public func rotate(_ orientation: RongYaoTeamViewOrientation, animated: Bool, completionHandler: @escaping (RongYaoTeamViewRotationManager)->() = {(_) in } ) {
        let ori_old = self.orientation
        let ori_new = orientation
        
        if ( ori_new == ori_old ) { completionHandler(self); return }
        guard let `window` = UIApplication.shared.keyWindow else { return }
        guard let `superview` = superview else { return }
        
        var transform = CGAffineTransform.identity
        var statusBarOrientation = UIInterfaceOrientation.unknown
        
        switch orientation {
        case .portrait:
            statusBarOrientation = .portrait
            if ( blackView.superview != nil ) { blackView.removeFromSuperview() }
        case .landscapeLeft:
            statusBarOrientation = .landscapeRight
            transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
        case .landscapeRight:
            statusBarOrientation = .landscapeLeft
            transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi/2))
        }
        
        if ( ori_old == .portrait ) {
            let frame = window.convert(target.frame, from: superview)
            target.frame = frame
            window.addSubview(target)
            con_portraitRect = frame
        }
        
        // update
        self.orientation = ori_new
        
        self.delegate?.rotationManager( self, willRotateView:self.isFullscreen)
        
        UIApplication.shared.statusBarOrientation = statusBarOrientation
        UIView.animate(withDuration: animated ? duration : 0, animations: {
            if ( ori_new == .portrait ) {
                self.target.bounds = CGRect.init(origin: .zero, size: self.con_portraitRect.size)
                self.target.center = CGPoint.init(x: self.con_portraitRect.origin.x + self.con_portraitRect.size.width * 0.5, y: self.con_portraitRect.origin.y + self.con_portraitRect.size.height * 0.5)
            }
            else {
                let width = UIScreen.main.bounds.size.width
                let height = UIScreen.main.bounds.size.height
                let _max = max(width, height)
                let _min = min(width, height)
                self.target.bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
                self.target.center = CGPoint.init(x: _min * 0.5, y: _max * 0.5)
            }
            self.target.transform = transform
        }) { (_) in
            if ( self.orientation == .portrait ) {
                superview.addSubview(self.target)
                self.reviser?.targetNeedRestFrame(self)
                self.delegate?.rotationManager( self, didRotateView:self.isFullscreen)
            }
            else {
                self.blackView.bounds = self.target.bounds
                self.blackView.center = self.target.center
                self.blackView.transform = self.target.transform
                UIApplication.shared.keyWindow?.insertSubview(self.blackView, belowSubview: self.target)
                self.delegate?.rotationManager( self, didRotateView:self.isFullscreen)
                completionHandler(self)
            }
        }
    }
    
    
    private func observeDeviceOrientation() {
        if ( UIDevice.current.isGeneratingDeviceOrientationNotifications == false ) {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    private func removeDeviceOrientationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func deviceOrientationDidChange() {
        
        if ( self.disableAutorotation ) { return }
        
        let de_orientation = UIDevice.current.orientation
        switch de_orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            rec_deviceOrientation = de_orientation
        default:
            break
        }
        
        switch  de_orientation {
        case .portrait:
            if ( isSupportedPortrait ) {
                self.rotate(.portrait, animated: true)
            }
        case .landscapeLeft:
            if ( isSupportedLandscapeLeft ) {
                self.rotate(.landscapeLeft, animated: true)
            }
        case .landscapeRight:
            if ( isSupportedLandscapeRight ) {
                self.rotate(.landscapeRight, animated: true)
            }
        default: break
        }
    }
    
    /// 是否支持 Portrait
    private var isSupportedPortrait: Bool {
        return RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue == (autorotationSupportedOrientation.rawValue & RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue)
    }
    
    /// 是否支持 LandscapeLeft
    private var isSupportedLandscapeLeft: Bool {
        return RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue == (autorotationSupportedOrientation.rawValue & RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue)
    }
    
    /// 是否支持 LandscapeRight
    private var isSupportedLandscapeRight: Bool {
        return RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue == (autorotationSupportedOrientation.rawValue & RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue)
    }
    
    /// 当前方向是否与设备方向一致
    private var isCurrentOrientationAsDeviceOrientation: Bool {
        switch rec_deviceOrientation {
        case .portrait:
            if ( self.orientation == .portrait ) { return true }
        case .landscapeLeft:
            if ( self.orientation == .landscapeLeft ) { return true }
        case .landscapeRight:
            if ( self.orientation == .landscapeRight ) { return true }
        default: break
        }
        return false
    }
}

public protocol RongYaoTeamViewRotationManagerReviser {
    /// 旋转视图需要复位
    func targetNeedRestFrame(_ mgr: RongYaoTeamViewRotationManager)
}

extension RongYaoTeamPlayerView: RongYaoTeamViewRotationManagerReviser {
    public func targetNeedRestFrame(_ mgr: RongYaoTeamViewRotationManager) {
        self.presentView.frame = self.bounds
    }
}

/// class - 视频画面呈现视图
fileprivate class RongYaoTeamPlayerPresentView: UIView {
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    fileprivate var avVideoGravity: AVLayerVideoGravity = AVLayerVideoGravity.resizeAspect { didSet{ self.playerLayer.videoGravity = avVideoGravity } }
    
    fileprivate func setAVPlayer(_ avPlayer: AVPlayer?) {
        if ( avPlayer == self.playerLayer.player ) { return }
        self.playerLayer.player = avPlayer
    }
    
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
}

fileprivate class RongYaoTeamGestureControl: NSObject {
    init(_ container: UIView) {
        super.init()
        
        self.container = container
        singleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleSingleTap))
        configGesture(singleTap)
        
        doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        configGesture(doubleTap)
        
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        configGesture(panGesture)
        
        pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch))
        configGesture(pinchGesture)
        
        singleTap.require(toFail: doubleTap)
        doubleTap.require(toFail: panGesture)
        
        container.addGestureRecognizer(singleTap)
        container.addGestureRecognizer(doubleTap)
        container.addGestureRecognizer(panGesture)
        container.addGestureRecognizer(pinchGesture)
    }
    
    weak var container: UIView!
    
    var singleTap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    var pinchGesture: UIPinchGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    
    @objc func handleSingleTap() {
        
    }
    
    @objc func handleDoubleTap() {
        
    }
    
    @objc func handlePan() {
        
    }
    
    @objc func handlePinch() {
        
    }
    
    private func configGesture(_ gesture: UIGestureRecognizer) {
        gesture.delegate = self
        gesture.delaysTouchesBegan = true
    }
}

extension RongYaoTeamGestureControl: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if ( gestureRecognizer == pinchGesture ) {
            if ( pinchGesture.numberOfTouches <= 1 ) { return false }
            else { return true }
        }
        
        
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
