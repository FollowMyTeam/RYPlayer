//
//  RYTabBarController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/17.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class RYTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    override var shouldAutorotate: Bool {
        if let vc = ry_topViewController() {
            return vc.shouldAutorotate
        }
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = ry_topViewController() {
            return vc.supportedInterfaceOrientations
        }
        
        return .allButUpsideDown
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = ry_topViewController() {
            return vc.preferredInterfaceOrientationForPresentation
        }
        
        return .portrait
    }
    
    private func ry_topViewController() -> UIViewController? {
        if let viewControllers = self.viewControllers {
            if ( viewControllers.count <= 5 || self.selectedIndex < 4 ) {
                if let vc = self.selectedViewController! as? UINavigationController {
                    return vc.topViewController
                }
                else {
                    return self.selectedViewController
                }
            }
            
            if ( self.selectedViewController == self.moreNavigationController ) {
                return self.moreNavigationController
            }
            
            return self.moreNavigationController.topViewController
        }
        else {
            return nil
        }
    }

}
