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
        topView = RongYaoTeamPlayerEdgeControlLayerTopView(frame: .zero)
        leftView = RongYaoTeamPlayerEdgeControlLayerLeftView(frame: .zero)
        bottomView = RongYaoTeamPlayerEdgeControlLayerBottomView(frame: .zero)
        rightView = RongYaoTeamPlayerEdgeControlLayerRightView(frame: .zero)
        
        self.addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(leftView)
        contentView.addSubview(bottomView)
        contentView.addSubview(rightView)
        
        topView.backgroundColor = .green
        leftView.backgroundColor = .green
        bottomView.backgroundColor = .green
        rightView.backgroundColor = .green
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(topView.superview!)
            make.height.equalTo(60)
        }
        
        leftView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.leading.centerY.equalTo(leftView.superview!)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(bottomView.superview!)
            make.height.equalTo(60)
        }
        
        rightView.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.trailing.centerY.equalTo(rightView.superview!)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
