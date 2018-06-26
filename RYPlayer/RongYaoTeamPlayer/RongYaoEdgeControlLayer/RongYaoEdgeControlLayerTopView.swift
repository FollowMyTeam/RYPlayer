//
//  RongYaoEdgeControlLayerTopView.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/24.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

/// 边缘控制层 - 上

public class RongYaoEdgeControlLayerTopView: UIView {
    
    public var topResrouces: RongYaoEdgeControlLayerResources.TopViewResources?
    
    public var rightButtonItems: [RongYaoButtonItem]? { didSet{ rightButtonItemsDidChange() } }
    
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var buttonItemsContainerView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        backButton = UIButton.init(type: .custom)
        backButton.addTarget(self, action: #selector(clickedBackBtn), for: .touchUpInside)
        self.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.size.equalTo(49)
            make.leading.bottom.equalTo(0)
        }

        backButton.setContentHuggingPriority(.required, for: .horizontal)
        backButton.setContentHuggingPriority(.required, for: .vertical)
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        backButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        buttonItemsContainerView = UIView.init()
        self.addSubview(buttonItemsContainerView)
        buttonItemsContainerView.snp.makeConstraints { (make) in
            make.bottom.trailing.equalTo(0)
            make.height.equalTo(backButton)
            make.width.greaterThanOrEqualTo(8)
        }
        
        titleLabel = UILabel.init()
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(backButton.snp.trailing)
            make.centerX.equalTo(backButton)
            make.trailing.equalTo(buttonItemsContainerView.snp.leading)
        }
    }
    
    private func rightButtonItemsDidChange() {
        
    }
    
    @objc private func clickedBackBtn() {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
}
