//
//  RongYaoTeamPlayerEdgeControlLayer.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

/// 边缘控制层
public class RongYaoTeamPlayerEdgeControlLayer: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private var contentView: UIView!
    private var topView: RongYaoTeamPlayerEdgeControlLayerTopView!
    private var leftView: RongYaoTeamPlayerEdgeControlLayerLeftView!
    private var bottomView: RongYaoTeamPlayerEdgeControlLayerBottomView!
    private var rightView: RongYaoTeamPlayerEdgeControlLayerRightView!
    
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

extension RongYaoTeamPlayerEdgeControlLayer {
    fileprivate func addTopView(_ superview: UIView) {
        topView = RongYaoTeamPlayerEdgeControlLayerTopView(frame: .zero)
        superview.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(topView.superview!)
            make.height.equalTo(60)
        }
    }
}

extension RongYaoTeamPlayerEdgeControlLayer {
    fileprivate func addLeftView(_ superview: UIView) {
        leftView = RongYaoTeamPlayerEdgeControlLayerLeftView(frame: .zero)
        superview.addSubview(leftView)
        leftView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.leading.centerY.equalTo(leftView.superview!)
        }
    }
}

extension RongYaoTeamPlayerEdgeControlLayer {
    fileprivate func addBottomView(_ superview: UIView) {
        bottomView = RongYaoTeamPlayerEdgeControlLayerBottomView(frame: .zero)
        superview.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(bottomView.superview!)
            make.height.equalTo(60)
        }
    }
}

extension RongYaoTeamPlayerEdgeControlLayer {
    fileprivate func addRightView(_ superview: UIView) {
        rightView = RongYaoTeamPlayerEdgeControlLayerRightView(frame: .zero)
        superview.addSubview(rightView)
        rightView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.trailing.centerY.equalTo(rightView.superview!)
        }
    }
}
