//
//  RongYaoMultidelegateManager.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import Foundation

/// 暂未使用

public class RongYaoMultidelegateManager<Element> {
    
    /// 添加一个代理
    /// - 此处为弱引用
    public func add(_ delegate: Element) {
        delegates.addPointer(ry_bridge(obj: delegate as AnyObject))
    }
    
    /// 删除
    public func remove(_ delegate: Element) {
        for i in 0...(delegates.count-1) {
            let d = delegates.pointer(at: i)
            if ( d == ry_bridge(obj: delegate as AnyObject) ) {
                delegates.removePointer(at: i)
                return
            }
        }
    }
    
    /// 获取全部代理
    public func all() -> Array<Element> {
        var arr = Array<Element>()
        for i in 0...(delegates.count-1) {
            guard let pointer = delegates.pointer(at: i) else { break }
            let de = ry_bridge(ptr: pointer)
            arr.append(de as! Element)
        }
        return arr
    }
 
    private var delegates: NSPointerArray = NSPointerArray.weakObjects()
}


