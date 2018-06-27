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

public protocol RongYaoEdgeControlLayerTopViewDelegate {
    func clickedBackButtonOnTopView(_ view: RongYaoEdgeControlLayerTopView)
}

public class RongYaoEdgeControlLayerTopView: RongYaoEdgeControlLayerView {
    
    public weak var delegate: (AnyObject & RongYaoEdgeControlLayerTopViewDelegate)?
    
    public var topResrouces: RongYaoEdgeControlLayerResources.TopViewResources? { didSet{ topViewResourcesDidChange() } }
    public var rightButtonItems: [RongYaoButtonItem]? { didSet{ rightButtonItemsDidChange() } }
    
    public var backButton: UIButton!
    public var titleLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        disappearType = [.alpha, .transform]
    }
    
    public override var intrinsicContentSize: CGSize {
        var height: CGFloat = 55
        if let `player` = player {
            if player.view.rotationManager.isFullscreen {
                height = 75
            }
        }
        return CGSize.init(width: UIScreen.main.bounds.width, height: height)
    }
    
    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        self.transformOfDisappear = .init(translationX: 0, y: -self.intrinsicContentSize.height)
    }
    
    private var rotationObserver: RongYaoTeamRotationManager.Observer?
    
    override func playerDidSet() {
        rotationObserver = player?.view.rotationManager.getObserver()
        rotationObserver?.setViewWillRotateExeBlock({ [weak self] (mgr) in
            guard let `self` = self else { return }
            self.invalidateIntrinsicContentSize()
        })
        invalidateIntrinsicContentSize()
    }
    
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
    
    private var buttonItemsContainerView: UIView!
    private func rightButtonItemsDidChange() {
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
    
    private func topViewResourcesDidChange() {
        
    }
    
    @objc private func clickedBackBtn() {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        self.delegate?.clickedBackButtonOnTopView(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
