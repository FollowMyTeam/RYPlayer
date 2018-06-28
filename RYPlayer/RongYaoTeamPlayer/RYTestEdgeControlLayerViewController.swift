//
//  RYTestEdgeControlLayerViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

class RYTestEdgeControlLayerViewController: UIViewController {
    
    var edgeControlLayer: RongYaoEdgeControlLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgeControlLayer = RongYaoEdgeControlLayer()
        
        edgeControlLayer.backgroundColor = .white
        view.backgroundColor = .purple
        
        view.addSubview(edgeControlLayer)
        edgeControlLayer.snp.makeConstraints { (make) in
            make.top.equalTo(200)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(9/16.0)
        }
        
        testTopView()
        
        // Do any additional setup after loading the view.
    }
    
    func testTopView() {
        let item1 = RongYaoButtonItem.init(#imageLiteral(resourceName: "set"), target: self, action: #selector(action))
        let item2 = RongYaoButtonItem.init(#imageLiteral(resourceName: "set"), target: self, action: #selector(action))
        let item3 = RongYaoButtonItem.init(#imageLiteral(resourceName: "set"), target: self, action: #selector(action))
        
        edgeControlLayer.topView.rightButtonItems = [item1,item2,item3]
        
        edgeControlLayer.topView.backButton.setImage(#imageLiteral(resourceName: "set"), for: .normal)
        edgeControlLayer.topView.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        edgeControlLayer.topView.titleLabel.textColor = .white
        edgeControlLayer.topView.titleLabel.text = "从管理的角度如何提高员工的工作效率"
    }
    
    @objc func action() {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    /// 禁止控制器视图旋转
    override var shouldAutorotate: Bool {
        return false
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

}
