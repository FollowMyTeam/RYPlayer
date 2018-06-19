//
//  ViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

class Text: NSObject {
    
}

class Tettt: Text {
    
}

class ViewController: UIViewController {
    
    
    public var rotationManager: RongYaoTeamViewRotationManager?
    
    
    public let rotationView: UIView = UIView.init()
    
    override func viewDidLoad() {
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        let te = Tettt.init()
        
        print(te as Tettt)
        
        rotationView.backgroundColor = UIColor.green
        self.view.addSubview(rotationView)
        
        rotationView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset((8))
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(rotationView.snp.width).multipliedBy(9/16.0);
        }
        
        rotationManager = RongYaoTeamViewRotationManager.init(target: rotationView, superview: self.view)
    }
    
    func test() {
        print("exe")
        
//        UIInterfaceOrientationMask
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

