//
//  RongYaoTeamRotationManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

// MARK: - 旋转管理

public extension RongYaoTeamRotationManager {
    /// 获取一个观察者
    /// - 当视图将要旋转时, 将会调用观察者的相应方法
    /// - 同样, 旋转完毕后, 也会调用相应方法
    func getObserver() -> RongYaoTeamRotationManager.Observer {
        return _Observer.init(self);
    }
    
    /// 观察者
    class Observer {
        /// 视图将要旋转
        public var viewWillRotateExeBlock: ((_ mgr: RongYaoTeamRotationManager)->())?
        public func setViewWillRotateExeBlock(_ block: ((_ mgr: RongYaoTeamRotationManager)->())?) {
            viewWillRotateExeBlock = block
        }
        
        /// 视图完成旋转
        public var viewDidEndRotateExeBlock: ((_ mgr: RongYaoTeamRotationManager)->())?
        public func setViewDidEndRotateExeBlock(_ block: ((_ mgr: RongYaoTeamRotationManager)->())?) {
            viewDidEndRotateExeBlock = block
        }
    }
}

/// RongYaoTeamRotationManager - 旋转管理类
/// - 设置自动旋转支持的方向
/// - 设置旋转动画持续时间
/// - 手动旋转到指定方向
/// - 是否禁止自动旋转
/// - 代理
///
/// 注意:
/// - 当全屏时, 旋转管理类将会把目标(target)视图添加到window中
public class RongYaoTeamRotationManager {

    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamRotationManager")
        #endif
        self.blackView.removeFromSuperview()
        self.removeDeviceOrientationObserver()
    }
    
    /// 实例化一个旋转管理对象
    ///
    /// - Parameters:
    ///   - target:            目标视图, 用来旋转的视图
    ///   - superview:         父视图, 旋转视图的父视图
    ///
    /// - 使用注意:
    ///   - 目标视图(target)的大小需与父视图相等, 如下:
    ///     ```Swift
    ///         // - 使用frame布局时:
    ///         target.frame = superview.bounds
    ///
    ///         // - 使用autolayout布局时:
    ///         target.snp.makeConstraints { (make) in
    ///             make.edges.equalTo(superview)
    ///         }
    ///     ```
    public init(target: UIView, superview: UIView) {
        self.target = target
        self.superview = superview
        observeDeviceOrientation()
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamRotationManagerDelegate)?
    
    /// 是否禁止自动旋转
    /// - 该属性只会禁止自动旋转, 当调用 rotate 等方法还是可以旋转的
    /// - 默认为 false
    public var disableAutorotation: Bool = false
    
    /// 是否正在旋转
    public var transitioning: Bool = false
    
    /// 自动旋转时, 所支持的方法
    /// - 默认为 .all
    public var autorotationSupportedOrientation: AutorotationSupportedOrientation = AutorotationSupportedOrientation.all
    
    /// 当前的方向
    public var currentOrientation: Orientation { return orientation }
    
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
            case .portrait, .landscapeLeft:
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
    
    private var con_portraitRect: CGRect = .zero
    
    /// 旋转视图
    public fileprivate(set) weak var target: UIView!
    
    /// 旋转视图的父视图
    public fileprivate(set) weak var superview: UIView!

    /// 记录的设备方向
    /// - 只记录三种设备方向 `.portrait, .landscapeLeft, .landscapeRight`
    private var rec_deviceOrientation: UIDeviceOrientation = .portrait
    
    /// - Any value of `Orientation`
    private var orientation: Orientation = .portrait

    /// 全屏时的背景视图
    private var blackView: UIView = {
        let blackView = UIView.init()
        blackView.backgroundColor = UIColor.black
        return blackView
    }()
    
    /// 旋转到指定方向
    public func rotate(_ orientation: Orientation, animated: Bool, completionHandler: @escaping (RongYaoTeamRotationManager)->() = {(_) in } ) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if ( self.transitioning ) { return }
            guard let `superview` = self.superview else { return }
            guard let `target` = self.target else { return }
            let ori_old = self.orientation
            let ori_new = orientation
            if ( ori_new == ori_old ) { completionHandler(self); return }
            guard let `window` = UIApplication.shared.keyWindow else { return }
            
            var transform = CGAffineTransform.identity
            var statusBarOrientation = UIInterfaceOrientation.unknown
            
            switch ori_new {
            case .portrait:
                statusBarOrientation = .portrait
                if ( self.blackView.superview != nil ) { self.blackView.removeFromSuperview() }
            case .landscapeLeft:
                statusBarOrientation = .landscapeRight
                transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
            case .landscapeRight:
                statusBarOrientation = .landscapeLeft
                transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi/2))
            }
            
            if ( ori_old == .portrait ) {
                target.translatesAutoresizingMaskIntoConstraints = true
                let frame = window.convert(target.frame, from: superview)
                target.frame = frame
                window.addSubview(target)
                self.con_portraitRect = frame
            }
            
            // update
            self.orientation = ori_new
            
            self.transitioning = true
            self.delegate?.rotationManager( self, viewWillRotate:self.isFullscreen)
            NotificationCenter.default.post(name: RongYaoTeamRotationManager.ViewWillRotate, object: self)
            UIApplication.shared.statusBarOrientation = statusBarOrientation
            UIView.animate(withDuration: animated ? self.duration : 0, animations: {
                if ( ori_new == .portrait ) {
                    target.transform = transform
                    target.bounds = CGRect.init(origin: .zero, size: self.con_portraitRect.size)
                    target.center = CGPoint.init(x: self.con_portraitRect.origin.x + self.con_portraitRect.size.width * 0.5, y: self.con_portraitRect.origin.y + self.con_portraitRect.size.height * 0.5)
                    target.layoutIfNeeded()
                }
                else {
                    let width = UIScreen.main.bounds.size.width
                    let height = UIScreen.main.bounds.size.height
                    let _max = max(width, height)
                    let _min = min(width, height)
                    target.bounds = CGRect.init(x: 0, y: 0, width: _max, height: _min)
                    target.center = CGPoint.init(x: _min * 0.5, y: _max * 0.5)
                    target.layoutIfNeeded()
                    target.transform = transform
                }
            }) { (_) in
                if ( self.orientation == .portrait ) {
                    superview.addSubview(self.target)
                    target.frame = superview.bounds
                }
                else {
                    self.blackView.bounds = target.bounds
                    self.blackView.center = target.center
                    self.blackView.transform = target.transform
                    window.insertSubview(self.blackView, belowSubview: target)
                }
                self.transitioning = false
                self.delegate?.rotationManager( self, viewDidEndRotate:self.isFullscreen)
                NotificationCenter.default.post(name: RongYaoTeamRotationManager.ViewDidEndRotate, object: self)
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
                print("\(#function) - \(#line) - RongYaoTeamRotationManager - 旋转被禁止, 暂时无法旋转!")
                #endif
                return
            }
            
            if let result = self.delegate?.triggerConditionForAutorotation(self) {
                if ( result == false ) {
                    #if DEBUG
                    print("\(#function) - \(#line) - RongYaoTeamRotationManager - 自动旋转触发条件返回false, 暂时无法旋转!")
                    #endif
                    return
                }
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
        return AutorotationSupportedOrientation.portrait.rawValue == (autorotationSupportedOrientation.rawValue & AutorotationSupportedOrientation.portrait.rawValue)
    }
    
    /// 是否支持 LandscapeLeft
    private var isSupportedLandscapeLeft: Bool {
        return AutorotationSupportedOrientation.landscapeLeft.rawValue == (autorotationSupportedOrientation.rawValue & AutorotationSupportedOrientation.landscapeLeft.rawValue)
    }
    
    /// 是否支持 LandscapeRight
    private var isSupportedLandscapeRight: Bool {
        return AutorotationSupportedOrientation.landscapeRight.rawValue == (autorotationSupportedOrientation.rawValue & AutorotationSupportedOrientation.landscapeRight.rawValue)
    }
    
    /// 当前方向是否与设备方向一致
    private var isCurrentOrientationAsDeviceOrientation: Bool {
        switch rec_deviceOrientation {
        case .landscapeLeft:
            if ( self.orientation == .landscapeLeft ) { return true }
        case .landscapeRight:
            if ( self.orientation == .landscapeRight ) { return true }
        default: break
        }
        return false
    }
}

public extension RongYaoTeamRotationManager {
    /// 方向
    ///
    /// - portrait:       竖屏
    /// - landscapeLeft:  全屏, Home键在右侧
    /// - landscapeRight: 全屏, Home键在左侧
    enum Orientation: UInt {
        case portrait = 0
        case landscapeLeft = 1
        case landscapeRight = 2
    }
    
    /// 自动旋转支持的方向
    struct AutorotationSupportedOrientation: OptionSet {
        
        /// 是否支持全屏
        public static var portrait: AutorotationSupportedOrientation { return AutorotationSupportedOrientation(rawValue: 1 << 0) }
        
        /// 是否支持全屏, Home键在右侧
        public static var landscapeLeft: AutorotationSupportedOrientation { return AutorotationSupportedOrientation(rawValue: 1 << 1) }
        
        /// 是否支持全屏, Home键在左侧
        public static var landscapeRight: AutorotationSupportedOrientation { return AutorotationSupportedOrientation(rawValue: 1 << 2) }
        
        /// 是否支持全部方向
        public static var all: AutorotationSupportedOrientation { return
            AutorotationSupportedOrientation(rawValue:
                    AutorotationSupportedOrientation.portrait.rawValue |
                    AutorotationSupportedOrientation.landscapeLeft.rawValue |
                    AutorotationSupportedOrientation.landscapeRight.rawValue) }
        
        /// init
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        /// value
        public var rawValue: UInt
    }
    
    /// 将要旋转的通知
    fileprivate static let ViewWillRotate: NSNotification.Name = NSNotification.Name.init("RongYaoTeamRotationManager.ViewWillRotate")
    
    /// 完成旋转的通知
    fileprivate static let ViewDidEndRotate: NSNotification.Name = NSNotification.Name.init("RongYaoTeamRotationManager.ViewDidEndRotate")
}

fileprivate class _Observer: RongYaoTeamRotationManager.Observer {
    fileprivate init(_ mgr: RongYaoTeamRotationManager) {
        super.init()
        notaToken1 = NotificationCenter.default.addObserver(forName: RongYaoTeamRotationManager.ViewWillRotate, object: mgr, queue: nil) { [weak self] (nota) in
            guard let `self` = self else { return }
            self.viewWillRotateExeBlock?(nota.object! as! RongYaoTeamRotationManager)
        }
        
        notaToken2 = NotificationCenter.default.addObserver(forName: RongYaoTeamRotationManager.ViewDidEndRotate, object: mgr, queue: nil) { [weak self] (nota) in
            guard let `self` = self else { return }
            self.viewDidEndRotateExeBlock?(nota.object! as! RongYaoTeamRotationManager)
        }
    }
    
    deinit {
        if let `notaToken1` = notaToken1 { NotificationCenter.default.removeObserver(notaToken1) }
        if let `notaToken2` = notaToken2 { NotificationCenter.default.removeObserver(notaToken2) }
    }
    
    private var notaToken1: Any?
    private var notaToken2: Any?
    
}

/// RongYaoTeamRotationManager - 代理
public protocol RongYaoTeamRotationManagerDelegate {

    /// 自动旋转的条件
    /// - 当触发自动旋转时, 管理类将会回调此方法
    /// - 返回true, 将会进行旋转. 反之, 则停止此次自动旋转
    func triggerConditionForAutorotation(_ mgr: RongYaoTeamRotationManager) -> Bool
    
    /// 将要旋转的回调
    func rotationManager(_ mgr: RongYaoTeamRotationManager, viewWillRotate isFullscreen: Bool)
    
    /// 完成旋转的回调
    func rotationManager(_ mgr: RongYaoTeamRotationManager, viewDidEndRotate isFullscreen: Bool)
}
