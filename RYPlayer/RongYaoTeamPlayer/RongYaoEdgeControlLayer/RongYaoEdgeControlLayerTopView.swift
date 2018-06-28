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

public class RongYaoEdgeControlLayerTopView: RongYaoEdgeControlLayerView {
    
    public weak var delegate: (AnyObject & RongYaoEdgeControlLayerTopViewDelegate)?
    
    public var topResrouces: RongYaoEdgeControlLayerResources.TopViewResources? { didSet{ topViewResourcesDidSet() } }
    
    public var rightButtonItems: [RongYaoButtonItem]? { didSet{ rightButtonItemsDidSet() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var buttonItemsContainerView: UIView!

    private func setupViews() {
        backButton = UIButton.init(type: .custom)
        backButton.addTarget(self, action: #selector(clickedBackBtn), for: .touchUpInside)
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.size.equalTo(49)
            make.leading.bottom.equalTo(0)
        }
        
        backButton.setContentHuggingPriority(.required, for: .horizontal)
        backButton.setContentHuggingPriority(.required, for: .vertical)
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        backButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        buttonItemsContainerView = UIView.init()
        addSubview(buttonItemsContainerView)
        buttonItemsContainerView.snp.makeConstraints { (make) in
            make.bottom.trailing.equalTo(0)
            make.height.equalTo(backButton)
            make.width.greaterThanOrEqualTo(8)
        }
        
        titleLabel = UILabel.init()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(backButton.snp.trailing)
            make.centerY.equalTo(backButton)
            make.trailing.equalTo(buttonItemsContainerView.snp.leading)
        }
    }
    
    private func rightButtonItemsDidSet() {
        for sub in buttonItemsContainerView.subviews { sub.removeFromSuperview() }
        guard let `rightButtonItems` = rightButtonItems else { return }
        if ( rightButtonItems.count == 0 ) { return }
        let itemMargin = 8
        for item in rightButtonItems {
            let itemView = RongYaoButtonItemView.init(item)
            let beforeView = buttonItemsContainerView.subviews.last
            buttonItemsContainerView.addSubview(itemView)
            itemView.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                if ( buttonItemsContainerView.subviews.count == 1 ) { make.leading.equalToSuperview().offset(itemMargin) }
                else { make.leading.equalTo(beforeView!.snp.trailing).offset(itemMargin)}
            }
        }
        buttonItemsContainerView.subviews.last!.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-itemMargin)
        }
    }
    
    private func topViewResourcesDidSet() {
        backButton.setImage(topResrouces?.backImage, for: .normal)
    }
    
    @objc private func clickedBackBtn() {
        self.delegate?.clickedBackButtonOnTopView(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public protocol RongYaoEdgeControlLayerTopViewDelegate {
    func clickedBackButtonOnTopView(_ view: RongYaoEdgeControlLayerTopView)
}
