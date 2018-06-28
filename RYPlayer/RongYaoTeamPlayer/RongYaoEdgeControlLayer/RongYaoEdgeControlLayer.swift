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
public class RongYaoEdgeControlLayer: UIView {
    
    private var controlLayerIsAppeared: Bool = true
    private var gestureManager: RongYaoTeamGestureManager!
    private var resources: RongYaoEdgeControlLayerResources!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGestures()
        setupResources()
    }

    private var contentView: UIView!
    private var topView: RongYaoEdgeControlLayerTopView!
    private var leftView: RongYaoEdgeControlLayerLeftView!
    private var bottomView: RongYaoEdgeControlLayerBottomView!
    private var rightView: RongYaoEdgeControlLayerRightView!

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
        //        topView.backgroundColor = .green
        leftView.backgroundColor = .green
        //        bottomView.backgroundColor = .green
        rightView.backgroundColor = .green
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension RongYaoEdgeControlLayer: RongYaoEdgeControlLayerResourcesDelegate {
    private func setupResources() {
        resources = RongYaoEdgeControlLayerResources.init(delegate: self)
    }
    public func resources(_ r: RongYaoEdgeControlLayerResources, loadingIsCompleted type: RongYaoEdgeControlLayerResources.ViewResourcesType) {
        switch type {
        case .top:
            topView.topResrouces = r.top
        case .left:
            break
        case .bottom:
            break
        case .right:
            break
        }
    }
}

extension RongYaoEdgeControlLayer: RongYaoTeamGestureManagerDelegate {
    
    private func setupGestures() {
        gestureManager = RongYaoTeamGestureManager.init(target: self)
        gestureManager.delegate = self
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

/// top
extension RongYaoEdgeControlLayer: RongYaoEdgeControlLayerTopViewDelegate {
    
    public var topViewRightButtonItems: [RongYaoButtonItem]? {
        set{ topView.rightButtonItems = newValue }
        get{ return topView.rightButtonItems }
    }
    
    
    
    fileprivate func addTopView(_ superview: UIView) {
        topView = RongYaoEdgeControlLayerTopView(frame: .zero)
        topView.maskStyle = .deepToShallow
        superview.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(topView.superview!)
            make.height.equalTo(55)
        }
    }
    
    public func clickedBackButtonOnTopView(_ view: RongYaoEdgeControlLayerTopView) {
        
    }
}

/// left
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

/// bottom
fileprivate extension RongYaoEdgeControlLayer {
    func addBottomView(_ superview: UIView) {
        bottomView = RongYaoEdgeControlLayerBottomView(frame: .zero)
        bottomView.maskStyle = .shallowToDeep
        superview.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(bottomView.superview!)
            make.height.equalTo(49)
        }
    }
}

/// right
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
