//
//  RYTestEdgeControlLayerViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

class RYTestEdgeControlLayerViewController: UIViewController, RongYaoEdgeControlLayerResourcesDelegate {
    
    var resources: RongYaoEdgeControlLayerResources!
    
    var edgeControlLayer: RongYaoEdgeControlLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .green
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        resources = RongYaoEdgeControlLayerResources.init(delegate: self)
        testTopView()
        
        // Do any additional setup after loading the view.
    }
    
    var topView: RongYaoEdgeControlLayerTopView!

    func testTopView() {
        let item1 = RongYaoButtonItem.init(#imageLiteral(resourceName: "set"), target: self, action: #selector(action))
        let item2 = RongYaoButtonItem.init(#imageLiteral(resourceName: "set"), target: self, action: #selector(action))
        let item3 = RongYaoButtonItem.init(#imageLiteral(resourceName: "set"), target: self, action: #selector(action))

        topView = RongYaoEdgeControlLayerTopView.init(frame: .zero)
        topView.maskStyle = .deepToShallow
        topView.rightButtonItems = [item1, item2, item3]
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(55)
        }
    }
    
    func resources(_ r: RongYaoEdgeControlLayerResources, loadingIsCompleted type: RongYaoEdgeControlLayerResources.ViewResourcesType) {
        switch type {
        case .top:
            topView.topResrouces = r.top
        default:
            break
        }
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
