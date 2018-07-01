//
//  RYTestGestureManagerViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/26.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class RYTestGestureManagerViewController: UIViewController {

    var gestureManager: RongYaoTeamGestureManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gestureManager = RongYaoTeamGestureManager.init(target: self.view)
        gestureManager.delegate = self
    
        gestureManager.supportedGestureTypes = [.singleTap]
        
        // Do any additional setup after loading the view.
    }
    
}

extension RYTestGestureManagerViewController: RongYaoTeamGestureManagerDelegate {
    func gestureManager(_ mgr: RongYaoTeamGestureManager, gestureShouldTrigger type: RongYaoTeamGestureManager.GestureType, location: CGPoint) -> Bool {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        
        return true
    }
    
    func triggerSingleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    func triggerDoubleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    func triggerPinchGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    func triggerPanGestureForGestureManager(_ mgr: RongYaoTeamGestureManager, state: RongYaoTeamGestureManager.PanGestureState, movingDirection: RongYaoTeamGestureManager.PanGestureMovingDirection, location: RongYaoTeamGestureManager.PanGestureLocation, translate: CGPoint) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
}
