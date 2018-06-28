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

public extension RongYaoEdgeControlLayer {
    /// 遮罩风格
    ///
    /// - none: 没有的
    /// - deepToShallow: 由深色到浅色
    /// - shallowToDeep: 由浅到深
    enum MaskStyle: Int {
        case none
        case deepToShallow
        case shallowToDeep
    }
}

public class RongYaoEdgeControlLayerView: UIView {
     
    /// 是否正在显示
    /// - default is true
    public private(set) var isAppeared: Bool = true
    
    internal var maskStyle: RongYaoEdgeControlLayer.MaskStyle = .none {
        didSet{
            if ( maskStyle.rawValue == oldValue.rawValue ) { return }
            let layer = self.layer as! CAGradientLayer
            switch maskStyle {
            case .none:
                layer.colors = nil
                break
            case .deepToShallow:
                layer.colors = [UIColor.init(white: 0, alpha: 0.42).cgColor, UIColor.clear.cgColor]
                break
            case .shallowToDeep:
                layer.colors = [UIColor.clear.cgColor, UIColor.init(white: 0, alpha: 0.42).cgColor]
                break
            }
        }
    }
    
    /// 隐藏类型
    /// - default is [.alpha]
    internal var disappearType: ViewDisappearTypes = [.alpha]
    
    /// 隐藏时的transform
    /// - default is .identity
    internal var transformOfDisappear: CGAffineTransform = CGAffineTransform.identity
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
}
