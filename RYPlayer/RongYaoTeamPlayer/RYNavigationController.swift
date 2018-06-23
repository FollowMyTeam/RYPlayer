//
//  RYNavigationController.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/17.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class RYNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    override var shouldAutorotate: Bool {
        if let topVC = self.topViewController {
            return topVC.shouldAutorotate
        }
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topVC = self.topViewController {
            return topVC.supportedInterfaceOrientations
        }
        return .allButUpsideDown
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let topVC = self.topViewController {
            return topVC.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        if let topVC = self.topViewController {
            return topVC.childViewControllerForStatusBarStyle
        }
        return self
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        if let topVC = self.topViewController {
            return topVC.childViewControllerForStatusBarHidden
        }
        return self
    }
}
