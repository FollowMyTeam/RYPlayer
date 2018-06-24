//
//  UIViewExtension+RongYao.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public struct RYViewDisappearTypes: OptionSet {

    public static var none: RYViewDisappearTypes { return RYViewDisappearTypes.init(rawValue: 0) }
    public static var alpha: RYViewDisappearTypes { return RYViewDisappearTypes.init(rawValue: 1 << 0) }
    public static var transform: RYViewDisappearTypes { return RYViewDisappearTypes.init(rawValue: 1 << 1) }
    public static var all: RYViewDisappearTypes { return RYViewDisappearTypes.init(rawValue: 1 << 2) }
    
    /// init
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// value
    public var rawValue: Int
    
}

public extension UIView {
    
    func ry_appear() {
        if ry_isNoneType() { return }
        
        if ry_hasAlphaType()  {
            self.alpha = 1
        }
        
        if ry_hasTransformType() {
            self.transform = .identity
        }
        
        ry_isAppeared = true
    }
    
    func ry_disappear() {
        if ry_isNoneType() { return }
        
        if ry_hasAlphaType()  {
            self.alpha = 0.001
        }
        
        if ry_hasTransformType() {
            self.transform = ry_transformOfDisappear
        }
        
        ry_isAppeared = false
    }
    
    /// default is true
    public private(set) var ry_isAppeared: Bool {
        set {
            objc_setAssociatedObject(self, &RYUIViewExtensionAssociatedKeys.kstate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var isAppeared = objc_getAssociatedObject(self, &RYUIViewExtensionAssociatedKeys.kstate) as? Bool
            if ( isAppeared == nil ) { isAppeared = true }
            return isAppeared!
        }
    }
    
    /// default is .none
    var ry_disappearType: RYViewDisappearTypes {
        set {
            objc_setAssociatedObject(self, &RYUIViewExtensionAssociatedKeys.kry_disappearType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var type = objc_getAssociatedObject(self, &RYUIViewExtensionAssociatedKeys.kry_disappearType) as? RYViewDisappearTypes
            if ( type == nil ) { type = .none }
            return type!
        }
    }
    
    /// default is .identity
    var ry_transformOfDisappear: CGAffineTransform {
        set {
            objc_setAssociatedObject(self, &RYUIViewExtensionAssociatedKeys.kry_transformOfDisappear, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var transform = objc_getAssociatedObject(self, &RYUIViewExtensionAssociatedKeys.kry_transformOfDisappear) as? CGAffineTransform
            if ( transform == nil ) { transform = CGAffineTransform.identity }
            return transform!
        }
    }
    
    private func ry_isNoneType() -> Bool {
        return RYViewDisappearTypes.none.rawValue == ry_disappearType.rawValue
    }
    
    private func ry_hasAlphaType() -> Bool {
        return RYViewDisappearTypes.alpha.rawValue == ( ry_disappearType.rawValue & RYViewDisappearTypes.alpha.rawValue )
    }
    
    private func ry_hasTransformType() -> Bool {
        return RYViewDisappearTypes.transform.rawValue == ( ry_disappearType.rawValue & RYViewDisappearTypes.transform.rawValue )
    }
    
    private struct RYUIViewExtensionAssociatedKeys {
        static var kry_disappearType = "ry_disappearType"
        static var kry_transformOfDisappear = "ry_transformOfDisappear"
        static var kstate = "kstate"
    }
}
