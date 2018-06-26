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
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public weak var player: RongYaoTeamPlayer?
    
    private var contentView: UIView!
    private var topView: RongYaoEdgeControlLayerTopView!
    private var leftView: RongYaoEdgeControlLayerLeftView!
    private var bottomView: RongYaoEdgeControlLayerBottomView!
    private var rightView: RongYaoEdgeControlLayerRightView!
    
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RongYaoEdgeControlLayer {
    fileprivate func addTopView(_ superview: UIView) {
        topView = RongYaoEdgeControlLayerTopView(frame: .zero)
        superview.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(topView.superview!)
            make.height.equalTo(60)
        }
    }
}

extension RongYaoEdgeControlLayer {
    fileprivate func addLeftView(_ superview: UIView) {
        leftView = RongYaoEdgeControlLayerLeftView(frame: .zero)
        superview.addSubview(leftView)
        leftView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.leading.centerY.equalTo(leftView.superview!)
        }
    }
}

extension RongYaoEdgeControlLayer {
    fileprivate func addBottomView(_ superview: UIView) {
        bottomView = RongYaoEdgeControlLayerBottomView(frame: .zero)
        superview.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(bottomView.superview!)
            make.height.equalTo(60)
        }
    }
}

extension RongYaoEdgeControlLayer {
    fileprivate func addRightView(_ superview: UIView) {
        rightView = RongYaoEdgeControlLayerRightView(frame: .zero)
        superview.addSubview(rightView)
        rightView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.trailing.centerY.equalTo(rightView.superview!)
        }
    }
}
