//
//  RongYaoEdgeControlLayerView.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit


public extension RongYaoEdgeControlLayerView {
    struct ViewDisappearTypes: OptionSet {
        public static var none: ViewDisappearTypes { return ViewDisappearTypes.init(rawValue: 0) }
        public static var alpha: ViewDisappearTypes { return ViewDisappearTypes.init(rawValue: 1 << 0) }
        public static var transform: ViewDisappearTypes { return ViewDisappearTypes.init(rawValue: 1 << 1) }
        public static var all: ViewDisappearTypes { return ViewDisappearTypes.init(rawValue: 1 << 2) }
        
        /// init
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// value
        public var rawValue: Int
    }
    
    
    func appear() {
        if isNoneType() { return }
        
        if hasAlphaType()  {
            self.alpha = 1
        }
        
        if hasTransformType() {
            self.transform = .identity
        }
        
        isAppeared = true
    }
    
    func disappear() {
        if isNoneType() { return }
        
        if hasAlphaType()  {
            self.alpha = 0.001
        }
        
        if hasTransformType() {
            self.transform = transformOfDisappear
        }
        
        isAppeared = false
    }
    
    private func isNoneType() -> Bool {
        return ViewDisappearTypes.none.rawValue == disappearType.rawValue
    }
    
    private func hasAlphaType() -> Bool {
        return ViewDisappearTypes.alpha.rawValue == ( disappearType.rawValue & ViewDisappearTypes.alpha.rawValue )
    }
    
    private func hasTransformType() -> Bool {
        return ViewDisappearTypes.transform.rawValue == ( disappearType.rawValue & ViewDisappearTypes.transform.rawValue )
    }
}

public class RongYaoEdgeControlLayerView: UIView {
    
    public var player: RongYaoTeamPlayer? {
        didSet{
            if ( oldValue == player ) { return }
            playerDidSet()
        }
    }
    
    private var rotationObserver: RongYaoTeamRotationManager.Observer?
    
    internal func playerDidSet() {
        rotationObserver = player?.view.rotationManager.getObserver()
        rotationObserver?.setViewWillRotateExeBlock({ [weak self] (mgr) in
            guard let `self` = self else { return }
            self.invalidateIntrinsicContentSize()
        })
        invalidateIntrinsicContentSize()
    }
    
    /// 是否正在显示
    /// - default is true
    public private(set) var isAppeared: Bool = true
    
    /// 隐藏类型
    /// - default is [.alpha]
    internal var disappearType: ViewDisappearTypes = [.alpha]
    
    /// 隐藏时的transform
    /// - default is .identity
    internal var transformOfDisappear: CGAffineTransform = CGAffineTransform.identity
}
