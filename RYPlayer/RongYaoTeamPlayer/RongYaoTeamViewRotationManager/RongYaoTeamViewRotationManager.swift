//
//  RongYaoTeamViewRotationManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit



public enum RongYaoTeamViewAutorotationOrientation: UInt {
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

public protocol RongYaoTeamViewRotationManagerDelegate {

}

public class RongYaoTeamViewRotationManager {

    public init(target: UIView, superview: UIView, delegate: (AnyObject & RongYaoTeamViewRotationManagerDelegate) ) {
        
    }
    
    
}
