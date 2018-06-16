//
//  ViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var function: (()->())?
    
    override func viewDidLoad() {
        function = self.test as ()->()
        function!()
        function!()
        function!()
        
    }
    
    func test() {
        print("exe")
    }
}

