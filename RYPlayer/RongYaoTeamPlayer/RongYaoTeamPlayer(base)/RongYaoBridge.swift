//
//  RongYaoBridge.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import Foundation

func ry_bridge(obj : AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(obj).toOpaque()
}

func ry_bridge(ptr : UnsafeRawPointer) -> AnyObject {
    return Unmanaged.fromOpaque(ptr).takeUnretainedValue()
}

func ry_bridgeRetained(obj : AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(obj).toOpaque()
}

func ry_bridgeTransfer(ptr : UnsafeRawPointer) -> AnyObject {
    return Unmanaged.fromOpaque(ptr).takeRetainedValue()
}
