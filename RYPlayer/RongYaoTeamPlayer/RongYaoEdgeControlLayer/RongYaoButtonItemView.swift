//
//  RongYaoButtonItemView.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/26.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

public class RongYaoButtonItemView: UIView {
    init(_ item: RongYaoButtonItem?) {
        super.init(frame: .zero)
        self.item = item
        self.clipsToBounds = true
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var item: RongYaoButtonItem? {
        didSet{
            if ( item == oldValue ) { return }
            itemDidChange(item, oldValue)
        }
    }
    
    public override func layoutSubviews() {
        superview?.layoutSubviews()
        
        print(self.bounds)
    }
    
    private var containerView: UIControl = UIControl.init()
    private var imageView: UIImageView?
    private var titleLabel: UILabel?
    
    private func itemDidChange(_ item: RongYaoButtonItem?, _ oldItem: RongYaoButtonItem?) {
        if let `oldItem` = oldItem {
            containerView.removeTarget(oldItem.target, action: oldItem.action, for: .touchUpInside)
        }
        
        oldItem?.customView?.removeFromSuperview()
        imageView?.removeFromSuperview()
        titleLabel?.removeFromSuperview()
        
        // action
        if let `action` = item?.action {
            containerView.addTarget(item!.target, action: action, for: .touchUpInside)
        }
        
        var itemWidth: CGFloat = 49
        if item?.width != 0 {
            itemWidth = item!.width
        }
        
        if let `customView` = item?.customView {
            containerView.addSubview(customView)
            customView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
                make.width.equalTo(itemWidth)
            }
        }
        else if let `image` = item?.image {
            if ( imageView == nil ) {
                imageView = UIImageView.init()
                imageView?.contentMode = .scaleAspectFit
            }
            imageView?.image = image
            containerView.addSubview(imageView!)
            imageView?.snp.remakeConstraints({ (make) in
                make.edges.equalToSuperview()
                make.width.equalTo(itemWidth)
            })
        }
        else if let `title` = item?.title {
            if ( titleLabel == nil ) {
                titleLabel = UILabel.init()
                titleLabel?.textAlignment = .center
            }
            titleLabel?.attributedText = title
            containerView.addSubview(titleLabel!)
            titleLabel?.snp.remakeConstraints({ (make) in
                make.edges.equalToSuperview()
                make.width.equalTo(itemWidth)
            })
        }
    }
}
