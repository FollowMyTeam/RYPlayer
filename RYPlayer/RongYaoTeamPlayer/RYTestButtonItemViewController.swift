//
//  RYTestButtonItemViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class RYTestButtonItemViewController: UIViewController {
    
    var containerView: RongYaoButtonItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView = RongYaoButtonItemView.init(nil)
        containerView.backgroundColor = UIColor.green
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.height.equalTo(49)
        }
        
//        testCustomView()
//        testImageItem()
        testTitleItem()
    }
    
    func testTitleItem() {
        let item = RongYaoButtonItem.init(NSAttributedString.init(string: "测试"), target: self, action: #selector(test))
//        item.width = 80
        containerView.item = item
    }
    
    func testImageItem() {
        let item = RongYaoButtonItem.init(#imageLiteral(resourceName: "helun"), target: self, action: #selector(test))
//        item.width = 80
        containerView.item = item
    }

    
    func testCustomView() {
        let customView = UIButton.init()
        customView.setTitle("测试", for: .normal)
        customView.addTarget(self, action: #selector(test), for: .touchUpInside)
        customView.backgroundColor = .orange
        let item = RongYaoButtonItem.init(customView)
//        item.width = 80
        containerView.item = item
    }
    
    
    func testItemEquel() {
        let item =  RongYaoButtonItem.init(NSAttributedString.init(string: "Test"), target: self, action: #selector(test))
        
        let item2: RongYaoButtonItem? = nil
        print(item == item2)
    }
    
    @objc func test() {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
}
