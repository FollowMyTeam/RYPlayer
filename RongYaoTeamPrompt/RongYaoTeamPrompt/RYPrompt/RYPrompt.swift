//
//  RYPrompt.swift
//  RongYaoTeamPrompt
//
//  Created by summer的Dad on 2018/6/23.
//  Copyright © 2018年 ZhuQiong. All rights reserved.
//

import UIKit
import SnapKit

class RYPrompt: NSObject {
    
    class func promptWithPresentView( _ presentView : UIView) -> (RYPrompt) {
       return  self.init(presentView: presentView)
    }
    
    public init ( presentView : UIView) {
        self.presentView = presentView
        super.init()
        self.setupView()
    }
    
    /// update config.
    public private(set) var updated: ((_ config : RYPromptConfig)->()) -> () = {(_) in}
   
    private let presentView : UIView!
    private var hiddenExeBlock : (_ prompt : RYPrompt)->() = {(_) in}
    
    
    /// reset config.
    func reset() {
        config.reset()
    }
    
    /*!
     *  duration if value set -1. promptView will always show.
     *
     *  duration 如果设置为 -1, 提示视图将会一直显示.
     */
    func showTitle(title: String , duration: TimeInterval , hiddenExeBlock: @escaping ((_ prompt: RYPrompt)->()) = {(_) in} ) -> () {
        guard title.count != 0 else {
            return
        }
        var dict: [NSAttributedStringKey:Any] = [NSAttributedStringKey:Any]()
      
        dict[.font] = self.config.font
        
        showAttributedString(attributedString: NSAttributedString.init(string: title, attributes:dict ), duration: duration, hiddenExeBlock)
    }
    
    func hidden() {
        _hidden()
    }
    
    func _show() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 1
        }
    }
    func showAttributedString(attributedString : NSAttributedString , duration : TimeInterval , _ hiddenExeBlock : @escaping ((_ prompt : RYPrompt)->()) = {(_) in }) -> () {
        guard attributedString.length != 0 else {
            return
        }
        
        DispatchQueue.main.async {
          self.hiddenExeBlock = hiddenExeBlock
            let maxWith = self.config.maxWidth != 0 ? self.config.maxWidth : self.presentView.frame.size.width * 0.6
            let size = self._sizeWithAttrString(attrStr: attributedString, width: CGFloat(maxWith!) , height: CGFloat.greatestFiniteMagnitude)
            self.promptLabel.attributedText = attributedString;
            self.promptLabel.snp.updateConstraints({ (snp) in
                snp.size.equalTo(size)
            })
            self._show()
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self._hidden), object: nil)
            if duration != -1 {
                self.perform(#selector(self._hidden), with: self, afterDelay: duration)
            }
        }
    }
    
    func _sizeWithAttrString(attrStr : NSAttributedString , width : CGFloat , height : CGFloat ) -> (CGSize) {
        let bounds = attrStr.boundingRect(with: CGSize.init(width: width, height: height), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.RawValue(UInt8(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue) | UInt8(NSStringDrawingOptions.usesFontLeading.rawValue))) , context: nil)
        return CGSize.init(width: bounds.size.width, height: bounds.size.height)
    }
    
    
    @objc func _hidden() {
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = 0.001
        }) { (finished) in
            self.hiddenExeBlock(self)
        }
    }
    
    func setupView() {
        presentView.addSubview(backgroundView)
        backgroundView.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(promptLabel.superview!)
            make.size.equalTo(0)
        }
        
        backgroundView.snp.makeConstraints { (snp) in
            snp.center.equalTo(presentView)
        }
    }

    lazy var backgroundView: UIView = {
        
        let view = UIView()
            view.clipsToBounds = true
            view.alpha = 0.0001
        return view
    }()
    
    lazy var promptLabel: UILabel = {
        let promptLabel = UILabel()
            promptLabel.numberOfLines = 0
            promptLabel.textAlignment = NSTextAlignment.center
        return promptLabel
    }()
   
    lazy var config: RYPromptConfig = {
        let fig = RYPromptConfig.init()
        return fig
    }()
    
}
