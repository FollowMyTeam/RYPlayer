//
//  RongYaoEdgeControlLayer.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

/// 边缘控制层
public class RongYaoEdgeControlLayer: UIView, RongYaoTeamGestureManagerDelegate {
    public weak var player: RongYaoTeamPlayer? { didSet{ playerDidSet() } }
    
    public var topView: RongYaoEdgeControlLayerTopView!
    public var leftView: RongYaoEdgeControlLayerLeftView!
    public var bottomView: RongYaoEdgeControlLayerBottomView!
    public var rightView: RongYaoEdgeControlLayerRightView!
    
    private var contentView: UIView!
    private var gestureManager: RongYaoTeamGestureManager!
    fileprivate var controlLayerIsAppeared: Bool = true
    
    private func setupViews() {
        clipsToBounds = true
        contentView = UIView.init()
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        addTopView(contentView)
        addLeftView(contentView)
        addBottomView(contentView)
        addRightView(contentView)

        /// test
        topView.backgroundColor = .green
        leftView.backgroundColor = .green
        bottomView.backgroundColor = .green
        rightView.backgroundColor = .green
    }
    
    private func playerDidSet() {
        topView.player = player
        leftView.player = player
        bottomView.player = player
        rightView.player = player
    }
    
    @objc private func test() {
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        gestureManager = RongYaoTeamGestureManager.init(target: self)
        gestureManager.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func gestureManager(_ mgr: RongYaoTeamGestureManager, gestureShouldTrigger type: RongYaoTeamGestureManager.GestureType, location: CGPoint) -> Bool {
        return true
    }
    
    public func triggerSingleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        UIView.animate(withDuration: 0.4) {
            if ( self.controlLayerIsAppeared ) {
                self.controlLayerNeedDisappear()
            }
            else {
                self.controlLayerNeedAppear()
            }
        }
    }
    
    public func triggerDoubleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        
    }
    
    public func triggerPinchGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        
    }
    
    public func triggerPanGestureForGestureManager(_ mgr: RongYaoTeamGestureManager, state: RongYaoTeamGestureManager.PanGestureState, movingDirection: RongYaoTeamGestureManager.PanGestureMovingDirection, location: RongYaoTeamGestureManager.PanGestureLocation, translate: CGPoint) {
        
    }
}

fileprivate extension RongYaoEdgeControlLayer {
    func controlLayerNeedAppear() {
        self.topView.appear()
        self.leftView.appear()
        self.bottomView.appear()
        self.rightView.appear()
        self.controlLayerIsAppeared = true
    }
    
    func controlLayerNeedDisappear() {
        self.topView.disappear()
        self.leftView.disappear()
        self.bottomView.disappear()
        self.rightView.disappear()
        self.controlLayerIsAppeared = false
    }
}

fileprivate  extension RongYaoEdgeControlLayer {
    func addTopView(_ superview: UIView) {
        topView = RongYaoEdgeControlLayerTopView(frame: .zero)
        superview.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(topView.superview!)
        }
    }
}

fileprivate extension RongYaoEdgeControlLayer {
    func addLeftView(_ superview: UIView) {
        leftView = RongYaoEdgeControlLayerLeftView(frame: .zero)
        superview.addSubview(leftView)
        leftView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.leading.centerY.equalTo(leftView.superview!)
        }
    }
}

fileprivate extension RongYaoEdgeControlLayer {
    func addBottomView(_ superview: UIView) {
        bottomView = RongYaoEdgeControlLayerBottomView(frame: .zero)
        superview.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(bottomView.superview!)
        }
    }
}

fileprivate extension RongYaoEdgeControlLayer {
    func addRightView(_ superview: UIView) {
        rightView = RongYaoEdgeControlLayerRightView(frame: .zero)
        superview.addSubview(rightView)
        rightView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.trailing.centerY.equalTo(rightView.superview!)
        }
    }
}
