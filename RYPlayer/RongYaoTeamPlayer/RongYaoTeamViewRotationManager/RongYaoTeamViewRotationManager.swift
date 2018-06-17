//
//  RongYaoTeamViewRotationManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit



public enum RongYaoTeamViewOrientation: UInt {
    case portrait = 0
    case landscapeLeft = 1
    case landscapeRight = 2
}


public struct RongYaoTeamViewAutorotationOrientationMask: OptionSet {
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public var rawValue: UInt
    
    public static var portrait: RongYaoTeamViewAutorotationOrientationMask { return RongYaoTeamViewAutorotationOrientationMask(rawValue: 1) }
    public static var landscapeLeft: RongYaoTeamViewAutorotationOrientationMask { return RongYaoTeamViewAutorotationOrientationMask(rawValue: 2) }
    public static var landscapeRight: RongYaoTeamViewAutorotationOrientationMask { return RongYaoTeamViewAutorotationOrientationMask(rawValue: 3) }
    public static var all: RongYaoTeamViewAutorotationOrientationMask { return RongYaoTeamViewAutorotationOrientationMask(rawValue: 4) }
}

public class RongYaoTeamViewRotationManager {

    public var orientation: RongYaoTeamViewOrientation = .portrait

    public var duration: TimeInterval = 0.25
    
    public init(target: UIView, superview: UIView ) {
        self.target = target
        self.superview = superview
    }
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamViewRotationManager")
        #endif
        self.removeDeviceOrientationObserver()
    }
    
    private var deviceOrientation: UIDeviceOrientation = .portrait
    private var superview: UIView
    private var target: UIView
    
    private func observeDeviceOrientation() {
        if ( UIDevice.current.isGeneratingDeviceOrientationNotifications == false ) {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDeviceOrientationChange)
//            name:UIDeviceOrientationDidChangeNotification object:nil];
//        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func handleDeviceOrientationChange() {
        
    }
    
    private func removeDeviceOrientationObserver() {
        
    }
}
