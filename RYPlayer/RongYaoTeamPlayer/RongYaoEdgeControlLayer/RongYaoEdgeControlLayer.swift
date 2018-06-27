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
    
    public convenience init(frame: CGRect, player: RongYaoTeamPlayer) {
        self.init(frame: frame)
        self.player = player
        playerDidSet()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public weak var player: RongYaoTeamPlayer? { didSet{ playerDidSet() } }
    
    private var contentView: UIView!
    
    public var topView: RongYaoEdgeControlLayerTopView!
    public var leftView: RongYaoEdgeControlLayerLeftView!
    public var bottomView: RongYaoEdgeControlLayerBottomView!
    public var rightView: RongYaoEdgeControlLayerRightView!
    
    private func setupViews() {
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
    
    private var rotationObserver: RongYaoTeamRotationManagerObserver?
    
    private func playerDidSet() {

        rotationObserver = self.player?.view.rotationManager.getObserver()
        rotationObserver?.viewWillRotateExeBlock = { [weak self] (mgr: RongYaoTeamRotationManager) in
            guard let `self` = self else { return }
            self.topViewUpdateLayout()
            self.bottomViewUpdateLayout()
        }
        
        rotationObserver?.viewDidEndRotateExeBlock = { [weak self] (mgr: RongYaoTeamRotationManager) in
            guard let `self` = self else { return }
            print(self)
        }
    }
    
    @objc private func test() {
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate  extension RongYaoEdgeControlLayer {
    func addTopView(_ superview: UIView) {
        topView = RongYaoEdgeControlLayerTopView(frame: .zero)
        superview.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(topView.superview!)
            make.height.equalTo(55)
        }
    }
    
    func topViewUpdateLayout() {
        topView.snp.updateConstraints { (make) in
            if (self.player?.view.rotationManager.isFullscreen)! { make.height.equalTo(75) }
            else { make.height.equalTo(55) }
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
 
    func leftViewUpdateLayout() {
        
    }
}

fileprivate extension RongYaoEdgeControlLayer {
    func addBottomView(_ superview: UIView) {
        bottomView = RongYaoEdgeControlLayerBottomView(frame: .zero)
        superview.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(bottomView.superview!)
            make.height.equalTo(49)
        }
    }
    
    func bottomViewUpdateLayout() {
        bottomView.snp.updateConstraints { (make) in
            if (self.player?.view.rotationManager.isFullscreen)! { make.height.equalTo(60) }
            else { make.height.equalTo(49) }
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
    
    
    func rightViewUpdateLayout() {
        
    }
}
