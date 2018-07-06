//
//  RYTestRotationViewController.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

class RYTestRotationViewController: UIViewController {

    var rotationManager: RongYaoTeamRotationManager!

    var testSuperview: UIView!
    var testTargetView: UIView!
    
    var containerView: UIView!
    var contentView: UIView!
    var topView: UIView!
    var bottomView: UIView!
    var centerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        testSuperview = UIView.init()
        testSuperview.backgroundColor = .black
        view.addSubview(testSuperview)
        testSuperview.snp.makeConstraints { (make) in
            make.top.equalTo(80)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(testSuperview.snp.width).multipliedBy(9/16.0)
        }
        
        
        testTargetView = UIView.init()
        testTargetView.backgroundColor = .green
        testSuperview.addSubview(testTargetView)
        testTargetView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        rotationManager = RongYaoTeamRotationManager.init(target: testTargetView, superview: testSuperview)
        rotationManager.delegate = self
        
        containerView = UIView.init()
        testTargetView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        contentView = UIView.init()
        containerView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        topView = UIView.init()
        contentView.addSubview(topView)
        topView.backgroundColor = UIColor.orange
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(0)
            make.height.equalTo(60)
        }
        
        bottomView = UIView.init()
        contentView.addSubview(bottomView)
        bottomView.backgroundColor = UIColor.orange
        bottomView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalTo(0)
            make.height.equalTo(60)
        }
        
        centerView = UIView.init()
        contentView.addSubview(centerView)
        centerView.backgroundColor = UIColor.orange
        centerView.snp.makeConstraints { (make) in
            make.center.equalTo(centerView.superview!)
            make.size.equalTo(60)
        }
        
        // Do any additional setup after loading the view.
    }
    
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

extension RYTestRotationViewController: RongYaoTeamRotationManagerDelegate {
    func triggerConditionForAutorotation(_ mgr: RongYaoTeamRotationManager) -> Bool {
        return true
    }
    
    func rotationManager(_ mgr: RongYaoTeamRotationManager, viewWillRotate isFullscreen: Bool) {
        #if DEBUG
        print("\(#function) - \(#line) - RYTestRotationViewController")
        #endif
    }
    
    func rotationManager(_ mgr: RongYaoTeamRotationManager, viewDidEndRotate isFullscreen: Bool) {
        #if DEBUG
        print("\(#function) - \(#line) - RYTestRotationViewController")
        #endif
    }
}
