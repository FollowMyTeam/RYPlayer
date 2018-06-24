//
//  RongYaoTeamPlayerView.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/19.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - 播放器视图

/// RongYaoTeamPlayerView - 播放器视图
/// - 呈现
/// - 旋转
/// - 手势
public class RongYaoTeamPlayerView: UIView {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
    }
    
    /// 旋转管理
    public private(set) var rotationManager: RongYaoTeamPlayerViewRotationManager!
    
    /// 手势管理
    public private(set) var gestureManager: RongYaoTeamPlayerViewGestureManager!

    /// 内容模式
    public var avVideoGravity: AVLayerVideoGravity {
        get{ return self.presentView.avVideoGravity }
        set{ self.presentView.avVideoGravity = newValue }
    }
    
    /// 设置avplayer, 呈现视频画面
    public func setAVPlayer(_ avPlayer: AVPlayer?) { self.presentView.setAVPlayer(avPlayer) }
    
    /// 呈现视频画面的视图
    private private(set) var presentView: RongYaoTeamPlayerPresentView = RongYaoTeamPlayerPresentView.init(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentView)
        rotationManager = RongYaoTeamPlayerViewRotationManager.init(target: self.presentView, superview: self)
        rotationManager.reviser = self
        presentView.backgroundColor = UIColor.black
        gestureManager = RongYaoTeamPlayerViewGestureManager.init(target: self.presentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        // 第一次初始化时, 设置frame
        if ( self.presentView.frame.isEmpty ) {
            presentView.frame = self.bounds
        }
    }
}












// MARK: - 旋转管理

/// RongYaoTeamPlayerViewRotationManager - 旋转管理类
/// - 设置自动旋转支持的方向
/// - 设置旋转动画持续时间
/// - 手动旋转到指定方向
/// - 是否禁止自动旋转
/// - 代理
public class RongYaoTeamPlayerViewRotationManager {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayerViewRotationManager")
        #endif
        self.blackView.removeFromSuperview()
        self.removeDeviceOrientationObserver()
    }
    
    public init(target: UIView, superview: UIView ) {
        self.target = target
        self.superview = superview
        observeDeviceOrientation()
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamPlayerViewRotationManagerDelegate)?
    
    /// 是否禁止自动旋转
    /// - 该属性只会禁止自动旋转, 当调用 rotate 等方法还是可以旋转的
    /// - 默认为 false
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
    /// - landscapeRight 或者 landscapeLeft 即为全屏
    public var isFullscreen: Bool { return ( orientation == .landscapeRight || orientation == .landscapeLeft ) }
    
    /// 旋转
    /// - Animated
    public func rotate() {
        // 如果是全屏状态 并且 支持 Portrait
        if ( self.isFullscreen && isSupportedPortrait ) {
            self.rotate(.portrait, animated: true)
            
            return
        }
        
        // 不是全屏或者不支持竖屏
        // 就是要全屏
        // 查看当前方向是否与设备方向一致
        // 如果不一致, 当前设备朝哪个方向, 就旋转到那个方向
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
        
        // 如果方向一致, 就旋转到相反的方向
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
    public fileprivate(set) weak var target: UIView!
    
    /// 旋转视图的父视图
    public fileprivate(set) weak var superview: UIView!
    
    /// 转回小屏时, 需进行修正
    public var reviser: (AnyObject & RongYaoTeamPlayerViewRotationManagerReviser)?
    
    
    
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
    public func rotate(_ orientation: RongYaoTeamViewOrientation, animated: Bool, completionHandler: @escaping (RongYaoTeamPlayerViewRotationManager)->() = {(_) in } ) {
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
        
        let de_orientation = UIDevice.current.orientation
        switch de_orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            rec_deviceOrientation = de_orientation
            if ( disableAutorotation ) {
                #if DEBUG
                print("\(#function) - \(#line) - RongYaoTeamPlayerViewRotationManager - 旋转被禁止, 暂时无法旋转!")
                #endif
                return
            }
        default: break
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

/// RongYaoTeamPlayerViewRotationManager - `播放器视图`方向
///
/// - portrait:       竖屏
/// - landscapeLeft:  全屏, Home键在右侧
/// - landscapeRight: 全屏, Home键在左侧
public enum RongYaoTeamViewOrientation: UInt {
    case portrait = 0
    case landscapeLeft = 1
    case landscapeRight = 2
}

/// RongYaoTeamPlayerViewRotationManager - `播放器视图`自动旋转支持的方向
public struct RongYaoTeamViewAutorotationSupportedOrientation: OptionSet {
    
    /// 是否支持全屏
    public static var portrait: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 0) }
    
    /// 是否支持全屏, Home键在右侧
    public static var landscapeLeft: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 1) }
    
    /// 是否支持全屏, Home键在左侧
    public static var landscapeRight: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 2) }
    
    /// 是否支持全部方向
    public static var all: RongYaoTeamViewAutorotationSupportedOrientation { return
        RongYaoTeamViewAutorotationSupportedOrientation(rawValue:
            RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue |
                RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue |
                RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue) }
    
    /// init
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// value
    public var rawValue: UInt
}

/// RongYaoTeamPlayerViewRotationManager - 代理
public protocol RongYaoTeamPlayerViewRotationManagerDelegate {
    /// 将要旋转的回调
    func rotationManager(_ mgr: RongYaoTeamPlayerViewRotationManager, willRotateView isFullscreen: Bool)
    
    /// 完成旋转的回调
    func rotationManager(_ mgr: RongYaoTeamPlayerViewRotationManager, didRotateView isFullscreen: Bool)
}

/// RongYaoTeamPlayerViewRotationManager - reviser
public protocol RongYaoTeamPlayerViewRotationManagerReviser {
    /// 旋转视图需要复位
    func targetNeedRestFrame(_ mgr: RongYaoTeamPlayerViewRotationManager)
}

/// RongYaoTeamPlayerView -
extension RongYaoTeamPlayerView: RongYaoTeamPlayerViewRotationManagerReviser {
    public func targetNeedRestFrame(_ mgr: RongYaoTeamPlayerViewRotationManager) {
        self.presentView.frame = self.bounds
    }
}

// MARK: - 画面呈现视图
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


// MARK: - 手势管理

/// RongYaoTeamPlayerViewGestureManager - 手势管理
/// - 设置支持的手势类型
/// - 代理
public class RongYaoTeamPlayerViewGestureManager: NSObject {
    
    public init(target: UIView) {
        super.init()
        self.target = target
        initializeGestures()
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamPlayerViewGestureManagerDelegate)?
    
    /// 设置支持的手势类型
    /// - 默认为 .all
    public var supportedGestureTypes: RongYaoTeamPlayerViewSupportedGestureTypes = .all
    
    
    fileprivate weak var target: UIView!
    
    private var singleTapGesture: UITapGestureRecognizer!
    private var doubleTapGesture: UITapGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    private var panLocation: RongYaoTeamPlayerViewPanGestureLocation = .unknown
    private var panMovingDirection: RongYaoTeamPlayerViewPanGestureMovingDirection = .unknown
    
    @objc private func handleSingleTap() {
        delegate?.triggerSingleTapGestureForGestureManager(self)
    }
    
    @objc private func handleDoubleTap() {
        delegate?.triggerDoubleTapGestureForGestureManager(self)
    }
    
    @objc private func handlePan() {
        let translate = panGesture.translation(in: panGesture.view!)
        
        switch panGesture.state {
        case .possible: break
        case .began:
            let velocity = panGesture.velocity(in: panGesture.view!)
            let x = fabs(velocity.x)
            let y = fabs(velocity.y)
            if x > y { panMovingDirection = .horizontal }
            else { panMovingDirection = .vertical }
            
            let locationPoint = panGesture.location(in: panGesture.view!)
            if ( locationPoint.x > panGesture.view!.bounds.width * 0.5 ) { panLocation = .right }
            else { panLocation = .left }
            
            delegate?.triggerPanGestureForGestureManager(self,
                                                         state: .began,
                                                         movingDirection: panMovingDirection,
                                                         location: panLocation,
                                                         translate: translate)
        case .changed:
            delegate?.triggerPanGestureForGestureManager(self,
                                                         state: .changed,
                                                         movingDirection: panMovingDirection,
                                                         location: panLocation,
                                                         translate: translate)
        case .failed, .cancelled, .ended:
            delegate?.triggerPanGestureForGestureManager(self,
                                                         state: .ended,
                                                         movingDirection: panMovingDirection,
                                                         location: panLocation,
                                                         translate: translate)
            panLocation = .unknown
            panMovingDirection = .unknown
        }
        
        panGesture.setTranslation(CGPoint.zero, in: panGesture.view!)
    }
    
    @objc private func handlePinch() {
        if pinchGesture.state == .began {
            delegate?.triggerPinchGestureForGestureManager(self)
        }
    }
    
    private func initializeGestures() {
        singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleSingleTap))
        configGesture(singleTapGesture)
        
        doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        configGesture(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        configGesture(panGesture)
        
        pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch))
        configGesture(pinchGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        doubleTapGesture.require(toFail: panGesture)
        
        target.addGestureRecognizer(singleTapGesture)
        target.addGestureRecognizer(doubleTapGesture)
        target.addGestureRecognizer(panGesture)
        target.addGestureRecognizer(pinchGesture)
    }
    
    private func configGesture(_ gesture: UIGestureRecognizer) {
        gesture.delegate = self
        gesture.delaysTouchesBegan = true
    }
    
    /// 是否支持某个手势
    fileprivate func isSupportedGesture(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == singleTapGesture {
            return isSupporedSingleTap()
        }
        else if gestureRecognizer == doubleTapGesture {
            return isSupportedDoubleTag()
        }
        else if gestureRecognizer == panGesture {
            return isSupportedPanGesture()
        }
        else if gestureRecognizer == pinchGesture {
            return isSupportedPinchGesture()
        }
        return false
    }
    
    /// 单击手势是否支持
    fileprivate func isSupporedSingleTap() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.singleTap.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.singleTap.rawValue)
    }
    
    /// 双击手势是否支持
    fileprivate func isSupportedDoubleTag() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.doubleTap.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.doubleTap.rawValue)
    }
    
    /// pan手势是否支持
    fileprivate func isSupportedPanGesture() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.pan.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.pan.rawValue)
    }
    
    /// 捏合手势是否支持
    fileprivate func isSupportedPinchGesture() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.pinch.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.pinch.rawValue)
    }
}

/// RongYaoTeamPlayerViewGestureManager - `播放器视图`默认添加的手势类型
///
/// - unknown:   未知
/// - singleTap: 单击
/// - doubleTap: 双击
/// - pan:       pan
/// - pinch:     捏合
public enum RongYaoTeamPlayerViewGestureType {
    case unknown
    case singleTap
    case doubleTap
    case pan
    case pinch
}

/// RongYaoTeamPlayerViewGestureManager - `播放器视图`默认支持的手势类型
public struct RongYaoTeamPlayerViewSupportedGestureTypes: OptionSet {
    
    /// 全部不支持
    public static var none: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 0) }
    
    /// 是否支持 单击手势
    public static var singleTap: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 0) }
    
    /// 是否支持 双击手势
    public static var doubleTap: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 1) }
    
    /// 是否支持 pan手势
    public static var pan: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 2) }
    
    /// 是否支持 捏合手势
    public static var pinch: RongYaoTeamPlayerViewSupportedGestureTypes { return RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue: 1 << 3) }
    
    /// 是否支持 全部手势
    public static var all: RongYaoTeamPlayerViewSupportedGestureTypes {  return
        RongYaoTeamPlayerViewSupportedGestureTypes.init(rawValue:
            RongYaoTeamPlayerViewSupportedGestureTypes.singleTap.rawValue |
                RongYaoTeamPlayerViewSupportedGestureTypes.doubleTap.rawValue |
                RongYaoTeamPlayerViewSupportedGestureTypes.pan.rawValue |
                RongYaoTeamPlayerViewSupportedGestureTypes.pinch.rawValue ) }
    
    /// init
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// value
    public var rawValue: UInt
}

/// RongYaoTeamPlayerViewGestureManager - pan手势触发的位置
///
/// - unknown: 未知
/// - left:    左半屏
/// - right:   右半屏
public enum RongYaoTeamPlayerViewPanGestureLocation: Int {
    case unknown
    case left
    case right
}

/// RongYaoTeamPlayerViewGestureManager - pan手势移动方向
///
/// - unknown:      未知
/// - vertical:     垂直方向移动
/// - horizontal:   水平方向移动
public enum RongYaoTeamPlayerViewPanGestureMovingDirection: Int {
    case unknown
    case vertical
    case horizontal
}

/// RongYaoTeamPlayerViewGestureManager - pan手势的状态
///
/// - unknown:  未知
/// - began:    手势开始触发
/// - changed:  手势触发中
/// - ended:    手势结束
public enum RongYaoTeamPlayerViewPanGestureState: Int {
    case unknown
    case began
    case changed
    case ended
}

/// RongYaoTeamPlayerViewGestureManager - 代理
public protocol RongYaoTeamPlayerViewGestureManagerDelegate {
    /// 用户touch的位置, 是否可以触发手势
    /// - 如果返回false, 不触发任何手势
    func gestureManager(_ mgr: RongYaoTeamPlayerViewGestureManager, gestureShouldTrigger type: RongYaoTeamPlayerViewGestureType, location: CGPoint) -> Bool
    
    /// 触发单击手势
    func triggerSingleTapGestureForGestureManager(_ mgr: RongYaoTeamPlayerViewGestureManager)
    /// 触发双击手势
    func triggerDoubleTapGestureForGestureManager(_ mgr: RongYaoTeamPlayerViewGestureManager)
    /// 触发捏合手势
    func triggerPinchGestureForGestureManager(_ mgr: RongYaoTeamPlayerViewGestureManager)
    /// 触发pan手势
    func triggerPanGestureForGestureManager(_ mgr: RongYaoTeamPlayerViewGestureManager, state: RongYaoTeamPlayerViewPanGestureState, movingDirection: RongYaoTeamPlayerViewPanGestureMovingDirection, location: RongYaoTeamPlayerViewPanGestureLocation, translate: CGPoint)
}

extension RongYaoTeamPlayerViewGestureManager: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if ( gestureRecognizer == pinchGesture ) {
            if ( pinchGesture.numberOfTouches <= 1 ) { return false }
        }
        
        if ( isSupportedGesture(gestureRecognizer) == false ) { return false }
        
        // pan 手势如果触发, 其他手势暂时不触发
        switch panGesture.state {
        case .began, .changed, .ended:
            return false
        default: break
        }
        
        // 如果没有代理, default触发任何默认手势
        guard let `delegate` = self.delegate else { return true }
        
        var type = RongYaoTeamPlayerViewGestureType.unknown
        
        if gestureRecognizer == singleTapGesture {
            type = .singleTap
        }
        else if gestureRecognizer == doubleTapGesture {
            type = .doubleTap
        }
        else if gestureRecognizer == panGesture {
            type = .pan
        }
        else if gestureRecognizer == pinchGesture {
            type = .pinch
        }
        
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        return delegate.gestureManager(self, gestureShouldTrigger: type, location: location)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if ( self.target.gestureRecognizers?.contains(otherGestureRecognizer) == false ) { return false }
        if ( gestureRecognizer.numberOfTouches >= 2 ) { return false }
        return true
    }
}
