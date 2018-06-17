//
//  ViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class Text: NSObject {
    
}

class Tettt: Text {
    
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        
        let te = Tettt.init()
        
        print(te as Tettt)
        

    }
    
    func test() {
        print("exe")
        
//        UIInterfaceOrientationMask
    }
}

