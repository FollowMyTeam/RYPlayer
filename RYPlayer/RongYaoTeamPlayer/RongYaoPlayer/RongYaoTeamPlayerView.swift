//
//  RongYaoTeamPlayerView.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/19.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

/// 视图方向
public enum RongYaoTeamViewOrientation: UInt {
    case portrait = 0
    case landscapeLeft = 1
    case landscapeRight = 2
}

/// 视图自动旋转支持的方向
public struct RongYaoTeamViewAutorotationSupportedOrientation: OptionSet {
    
    public static var portrait: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 0) }
    
    public static var landscapeLeft: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 1) }
    
    public static var landscapeRight: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 2) }
    
    public static var all: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue | RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue | RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue) }
    
    /// init
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// value
    public var rawValue: UInt
}

public protocol RongYaoTeamPlayerViewDelegate {
    func playerView(_ view: RongYaoTeamPlayerView, willBeRotated isFullscreen: Bool)
    func playerView(_ view: RongYaoTeamPlayerView, DidRotate isFullscreen: Bool)
}


public class RongYaoTeamPlayerView: UIView {
    public private(set) var playerLayerView: RongYaoTeamPlayerLayerView = RongYaoTeamPlayerLayerView.init(frame: .zero)
    
    public private(set) var rotationManager: RongYaoTeamViewRotationManager!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playerLayerView)
        rotationManager = RongYaoTeamViewRotationManager.init(target: self.playerLayerView, superview: self)
        rotationManager.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if ( self.playerLayerView.frame.isEmpty ) {
            playerLayerView.frame = self.bounds
        }
    }
    
}

public class RongYaoTeamPlayerLayerView: UIView {
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    public var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    public var avPlayer: AVPlayer? { didSet{ avPlayerDidChange() } }
    
    public var avVideoGravity: AVLayerVideoGravity = AVLayerVideoGravity.resizeAspect { didSet{ avLayerVideoGravityDidChange() } }
    
    private func avPlayerDidChange() {
        self.playerLayer.player = self.avPlayer
    }
    
    private func avLayerVideoGravityDidChange() {
        self.playerLayer.videoGravity = self.avVideoGravity
    }
}

extension RongYaoTeamPlayerView: RongYaoTeamViewRotationManagerDelegate {
    /// 视图将要旋转时的回调
    fileprivate func rotationManager(_ mgr: RongYaoTeamViewRotationManager, willRotateView isFullscreen: Bool) {
        
    }
    
    /// 视图旋转后的回调
    fileprivate func rotationManager(_ mgr: RongYaoTeamViewRotationManager, didRotateView isFullscreen: Bool) {
        
    }
    
    /// 旋转视图需要复位
    fileprivate func targetNeedRestFrame(_ mgr: RongYaoTeamViewRotationManager) {
        self.playerLayerView.frame = self.bounds
    }
}

fileprivate protocol RongYaoTeamViewRotationManagerDelegate {
    /// 视图将要旋转时的回调
    func rotationManager(_ mgr: RongYaoTeamViewRotationManager, willRotateView isFullscreen: Bool)
    
    /// 视图旋转后的回调
    func rotationManager(_ mgr: RongYaoTeamViewRotationManager, didRotateView isFullscreen: Bool)
    
    /// 旋转视图需要复位
    func targetNeedRestFrame(_ mgr: RongYaoTeamViewRotationManager)
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
    
    /// 旋转视图
    public fileprivate(set) var target: UIView
    
    /// 旋转视图的父视图
    /// - 用于转回小屏时进行复位
    public fileprivate(set) weak var superview: UIView?
    
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
            switch deviceOrientation {
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
        switch deviceOrientation {
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
    
    
// MARK: Private
    fileprivate weak var delegate: (AnyObject & RongYaoTeamViewRotationManagerDelegate)?
    
    /// 记录的设备方向
    /// - 只记录三种设备方向 `.portrait, .landscapeLeft, .landscapeRight`
    private var deviceOrientation: UIDeviceOrientation = .portrait
    
    /// - Any value of `RongYaoTeamViewOrientation`
    private var orientation: RongYaoTeamViewOrientation = .portrait
    
    private var con_portraitRect: CGRect = .zero
    
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
                self.delegate?.targetNeedRestFrame(self)
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
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamViewRotationManager")
        #endif
        
        if ( self.disableAutorotation ) { return }
        
        let de_orientation = UIDevice.current.orientation
        switch de_orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            deviceOrientation = de_orientation
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
        switch deviceOrientation {
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
