//
//  ViewController.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import SnapKit

class Text: NSObject {
    
}

class Tettt: Text {
    
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        let te = Tettt.init()
        
        print(te as Tettt)
        
        let a: Int = 1
        let b: Int = 3
        print(Float(a) / Float(b))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

