//
//  RongYaoTeamViewRotationManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public enum RongYaoTeamViewOrientation: UInt {
    case portrait = 0
    case landscapeLeft = 1
    case landscapeRight = 2
}


public struct RongYaoTeamViewAutorotationSupportedOrientation: OptionSet {
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public var rawValue: UInt
    
    public static var portrait: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 0) }
    public static var landscapeLeft: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 1) }
    public static var landscapeRight: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 2) }
    public static var all: RongYaoTeamViewAutorotationSupportedOrientation { return RongYaoTeamViewAutorotationSupportedOrientation(rawValue: 1 << 3) }
}

public protocol RongYaoTeamViewRotationManagerDelegate {
    
    /// 视图将要旋转时的回调
    func rotationManager(_ mgr: RongYaoTeamViewRotationManager, willRotateView isFullscreen: Bool)
    
    /// 视图旋转后的回调
    func rotationManager(_ mgr: RongYaoTeamViewRotationManager, didRotateView isFullscreen: Bool)
}

public class RongYaoTeamViewRotationManager {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamViewRotationManager")
        #endif
        self.removeDeviceOrientationObserver()
    }
    
    public init(target: UIView, superview: UIView ) {
        self.target = target
        self.superview = superview
        self.observeDeviceOrientation()
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamViewRotationManagerDelegate)?
    
    /// 自动旋转时, 所支持的方法
    /// - 默认为 .all
    public var autorotationSupportedOrientation: RongYaoTeamViewAutorotationSupportedOrientation = RongYaoTeamViewAutorotationSupportedOrientation.all
    
    /// 当前的方向
    /// - 视图当前旋转到的方法
    /// - Any value of `RongYaoTeamViewOrientation`, Animated
    public var orientation: RongYaoTeamViewOrientation = .portrait {
        didSet {
            if ( oldValue != orientation ) {
                orientationDidChange()
            }
        }
    }

    /// 动画持续的时间
    public var duration: TimeInterval = 0.25
    
    /// 旋转视图
    public private(set) var target: UIView
   
    /// 旋转视图的父视图
    /// - 用于转回小屏时进行复位
    public private(set) weak var superview: UIView?
    
    /// 是否全屏
    public var isFullscreen: Bool { return ( orientation == .landscapeRight || orientation == .landscapeLeft ) }
    
    
    /// 记录的设备方向
    /// - 只记录三种设备方向 `.portrait, .landscapeLeft, .landscapeRight`
    private var deviceOrientation: UIDeviceOrientation = .portrait
    
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

        let de_orientation = UIDevice.current.orientation
        switch de_orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            deviceOrientation = de_orientation
        default:
            break
        }

        switch  de_orientation {
        case .portrait:
            if ( RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue == (autorotationSupportedOrientation.rawValue & RongYaoTeamViewAutorotationSupportedOrientation.portrait.rawValue) ) {
                self.orientation = .portrait
            }
        case .landscapeLeft:
            if ( RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue == (autorotationSupportedOrientation.rawValue & RongYaoTeamViewAutorotationSupportedOrientation.landscapeLeft.rawValue) ) {
                self.orientation = .landscapeLeft
            }
        case .landscapeRight:
            if ( RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue == (autorotationSupportedOrientation.rawValue & RongYaoTeamViewAutorotationSupportedOrientation.landscapeRight.rawValue) ) {
                self.orientation = .landscapeLeft
            }
        default: break
        }
    }
    
    private func orientationDidChange() {
        
    }
}
