//
//  RongYaoTeamGestureManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

// MARK: - 手势管理

/// RongYaoTeamGestureManager - 手势管理
/// - 设置支持的手势类型
/// - 代理
public class RongYaoTeamGestureManager: NSObject {

    public init(target: UIView) {
        super.init()
        self.target = target
        addSingleTapGesture()
        addDoubleTapGesture()
        addPinchGesture()
        addPanGesture()
        singleTapGesture.require(toFail: doubleTapGesture)
        doubleTapGesture.require(toFail: panGesture)
    }
    
    public weak var delegate: (AnyObject & RongYaoTeamGestureManagerDelegate)?
    
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
    
}

extension RongYaoTeamGestureManager {
    fileprivate func addSingleTapGesture() {
        singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleSingleTap))
        configGesture(singleTapGesture)
        target.addGestureRecognizer(singleTapGesture)
    }
    
    @objc private func handleSingleTap() {
        delegate?.triggerSingleTapGestureForGestureManager(self)
    }
    
    /// 单击手势是否支持
    fileprivate func isSupporedSingleTap() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.singleTap.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.singleTap.rawValue)
    }
}

extension RongYaoTeamGestureManager {
    fileprivate func addDoubleTapGesture() {
        doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        configGesture(doubleTapGesture)
        target.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func handleDoubleTap() {
        delegate?.triggerDoubleTapGestureForGestureManager(self)
    }

    /// 双击手势是否支持
    fileprivate func isSupportedDoubleTag() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.doubleTap.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.doubleTap.rawValue)
    }
}

extension RongYaoTeamGestureManager {
    fileprivate func addPanGesture() {
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        configGesture(panGesture)
        target.addGestureRecognizer(panGesture)
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
    
    /// pan手势是否支持
    fileprivate func isSupportedPanGesture() -> Bool {
        return RongYaoTeamPlayerViewSupportedGestureTypes.pan.rawValue == (supportedGestureTypes.rawValue & RongYaoTeamPlayerViewSupportedGestureTypes.pan.rawValue)
    }
}

extension RongYaoTeamGestureManager {
    fileprivate func addPinchGesture() {
        pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch))
        configGesture(pinchGesture)
        target.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch() {
        if pinchGesture.state == .began {
            delegate?.triggerPinchGestureForGestureManager(self)
        }
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

/// RongYaoTeamGestureManager - `播放器视图`默认添加的手势类型
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

/// RongYaoTeamGestureManager - `播放器视图`默认支持的手势类型
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

/// RongYaoTeamGestureManager - pan手势触发的位置
///
/// - unknown: 未知
/// - left:    左半屏
/// - right:   右半屏
public enum RongYaoTeamPlayerViewPanGestureLocation: Int {
    case unknown
    case left
    case right
}

/// RongYaoTeamGestureManager - pan手势移动方向
///
/// - unknown:      未知
/// - vertical:     垂直方向移动
/// - horizontal:   水平方向移动
public enum RongYaoTeamPlayerViewPanGestureMovingDirection: Int {
    case unknown
    case vertical
    case horizontal
}

/// RongYaoTeamGestureManager - pan手势的状态
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

/// RongYaoTeamGestureManager - 代理
public protocol RongYaoTeamGestureManagerDelegate {
    /// 是否可以触发手势(用户touch的位置)
    /// - 如果返回false, 不触发手势
    func gestureManager(_ mgr: RongYaoTeamGestureManager, gestureShouldTrigger type: RongYaoTeamPlayerViewGestureType, location: CGPoint) -> Bool
    
    /// 触发单击手势
    func triggerSingleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager)
    /// 触发双击手势
    func triggerDoubleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager)
    /// 触发捏合手势
    func triggerPinchGestureForGestureManager(_ mgr: RongYaoTeamGestureManager)
    /// 触发pan手势
    func triggerPanGestureForGestureManager(_ mgr: RongYaoTeamGestureManager, state: RongYaoTeamPlayerViewPanGestureState, movingDirection: RongYaoTeamPlayerViewPanGestureMovingDirection, location: RongYaoTeamPlayerViewPanGestureLocation, translate: CGPoint)
}
