//
//  RYObserver.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public class RYObserver: NSObject {
    var observeKey: String?
    var exeBlock: ((RYObserver)->Void)
    var nota: Notification.Name?
    
    /// KVO
    var value_new: AnyObject?
    var value_old: AnyObject?
    init(owner: AnyObject, observeKey: String, exeBlock: @escaping (RYObserver)->Void ) {
        self.observeKey = observeKey
        self.exeBlock = exeBlock
        super.init()
        owner.addObserver(self, forKeyPath: observeKey, options: [.old, .new], context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        value_new = change?[NSKeyValueChangeKey.newKey] as AnyObject
        value_old = change?[NSKeyValueChangeKey.oldKey] as AnyObject
        if ( value_new?.isEqual(value_old) )! {
            return
        }
        self.exeBlock(self)
    }
    
    /// Notification
    init(owner: AnyObject, nota: Notification.Name, exeBlock: @escaping (RYObserver)->Void) {
        self.nota = nota;
        self.exeBlock = exeBlock
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: nota, object: owner)
    }
    
    @objc func handleNotification() {
        self.exeBlock(self)
    }
    
    /// Remove
    func remove(owner: AnyObject) {
        if ( observeKey != nil ) {
            owner.removeObserver(self, forKeyPath: observeKey!)
        }
        else if ( nota != nil ) {
            NotificationCenter.default.removeObserver(self, name: nota, object: owner)
        }
    }
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
}
