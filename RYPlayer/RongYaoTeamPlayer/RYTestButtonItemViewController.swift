//
//  RYTestButtonItemViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

class RYTestButtonItemViewController: UIViewController {
    
    
    var containerView: UIView!
    var itemView1: RongYaoButtonItemView!
    var itemView2: RongYaoButtonItemView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView = UIView.init()
        view.addSubview(containerView)
        
        itemView1 = RongYaoButtonItemView.init(nil)
        itemView1.backgroundColor = UIColor.green
        containerView.addSubview(itemView1)
        itemView1.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.height.equalTo(49)
        }
        
        itemView2 = RongYaoButtonItemView.init(nil)
        itemView2.backgroundColor = UIColor.gray
        containerView.addSubview(itemView2)
        itemView2.snp.makeConstraints { (make) in
            make.leading.equalTo(itemView1.snp.trailing)
            make.top.bottom.height.equalTo(itemView1)
            make.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        containerView.layoutIfNeeded()
        
        item = RongYaoButtonItem.init(NSAttributedString.init(string: "待操作"), target: self, action: #selector(test))
        item?.width = 80
        
        itemView1.item = item
        itemView2.item = item
    }
    
    func testItemEquel() {
        let item =  RongYaoButtonItem.init(NSAttributedString.init(string: "Test"), target: self, action: #selector(test))
        let item2 = item
        print(item == item2)
    }
    
    @objc func test() {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
    }
    
    
    var item: RongYaoButtonItem?
    
    @IBAction func isHidden(_ sender: Any) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        
        item?.isHidden = !(item?.isHidden)!
    }
    
    @IBAction func width(_ sender: Any) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        
        item?.isHidden = false
        item?.width = CGFloat(arc4random() % 50 + 30)
    }
    
    @IBAction func image(_ sender: Any) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        
        item?.width = 49
        item?.isHidden = false
        item?.customView = nil
        item?.title = nil
        item?.image = #imageLiteral(resourceName: "helun")
    }
    
    @IBAction func title(_ sender: Any) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        
        item?.width = 49
        item?.isHidden = false
        item?.customView = nil
        item?.title = NSAttributedString.init(string: "Test Test")
        item?.image = nil
    }
    
    
    @IBAction func custom(_ sender: Any) {
        #if DEBUG
        print("\(#function) - \(#line) - \(NSStringFromClass(self.classForCoder))")
        #endif
        let customView = UIButton.init()
        customView.setTitle("测试", for: .normal)
        customView.addTarget(self, action: #selector(test), for: .touchUpInside)
        customView.backgroundColor = .orange
        
        item?.width = 49
        item?.isHidden = false
        item?.customView = customView
        item?.title = nil
        item?.image = nil
    }
}
