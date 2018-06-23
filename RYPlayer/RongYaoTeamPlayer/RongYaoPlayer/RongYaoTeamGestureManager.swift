//
//  RongYaoTeamGestureManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

// MARK: - 手势管理

/// `播放器视图`默认添加的手势类型
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

/// `播放器视图`默认支持的手势类型
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

/// pan手势触发的位置
///
/// - unknown: 未知
/// - left:    左半屏
/// - right:   右半屏
public enum RongYaoTeamPlayerViewPanGestureLocation: Int {
    case unknown
    case left
    case right
}

/// pan手势移动方向
///
/// - unknown:      未知
/// - vertical:     垂直方向移动
/// - horizontal:   水平方向移动
public enum RongYaoTeamPlayerViewPanGestureMovingDirection: Int {
    case unknown
    case vertical
    case horizontal
}

/// pan手势的状态
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

public protocol RongYaoTeamGestureManagerDelegate {
    /// 用户touch到的位置, 是否可以触发手势, 如果返回false, 不触发任何手势
    func gestureManager(_ mgr: RongYaoTeamGestureManager, gestureShouldBegin type: RongYaoTeamPlayerViewGestureType, location: CGPoint) -> Bool
    
    /// 触发单击手势
    func triggerSingleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager)
    /// 触发双击手势
    func triggerDoubleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager)
    /// 触发捏合手势
    func triggerPinchGestureForGestureManager(_ mgr: RongYaoTeamGestureManager)
    /// 触发pan手势
    func triggerPanGestureForGestureManager(_ mgr: RongYaoTeamGestureManager, state: RongYaoTeamPlayerViewPanGestureState, movingDirection: RongYaoTeamPlayerViewPanGestureMovingDirection, location: RongYaoTeamPlayerViewPanGestureLocation)
}

/// 手势管理
public class RongYaoTeamGestureManager: NSObject {
    
    public init(_ container: UIView) {
        super.init()
        self.container = container
        initialize()
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamGestureManagerDelegate)?
    
    /// 设置支持的手势类型
    /// - 默认为全部手势
    public var supportedGestureTypes: RongYaoTeamPlayerViewSupportedGestureTypes = .all
    
    fileprivate weak var container: UIView!
    
    private var singleTap: UITapGestureRecognizer!
    private var doubleTap: UITapGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    
    @objc private func handleSingleTap() {
        
    }
    
    @objc private func handleDoubleTap() {
        
    }
    
    @objc private func handlePan() {
        
    }
    
    @objc private func handlePinch() {
        
    }
    
    private func initialize() {
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
    
    private func configGesture(_ gesture: UIGestureRecognizer) {
        gesture.delegate = self
        gesture.delaysTouchesBegan = true
    }
    
    /// 是否支持某个手势
    fileprivate func isSupportedGesture(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == singleTap {
            return isSupporedSingleTap()
        }
        else if gestureRecognizer == doubleTap {
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

extension RongYaoTeamGestureManager: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if ( gestureRecognizer == pinchGesture ) {
            if ( pinchGesture.numberOfTouches <= 1 ) { return false }
        }
        
        if ( isSupportedGesture(gestureRecognizer) == false ) { return false }
        
        // 如果没有代理, default触发任何默认手势
        guard let `delegate` = self.delegate else { return true }
        
        var type = RongYaoTeamPlayerViewGestureType.unknown
        
        if gestureRecognizer == singleTap {
            type = .singleTap
        }
        else if gestureRecognizer == doubleTap {
            type = .doubleTap
        }
        else if gestureRecognizer == panGesture {
            type = .pan
        }
        else if gestureRecognizer == pinchGesture {
            type = .pinch
        }
        
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        return delegate.gestureManager(self, gestureShouldBegin: type, location: location)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if ( self.container.gestureRecognizers?.contains(otherGestureRecognizer) == false ) { return false }
        if ( gestureRecognizer.numberOfTouches >= 2 ) { return false }
        return true
    }
}
