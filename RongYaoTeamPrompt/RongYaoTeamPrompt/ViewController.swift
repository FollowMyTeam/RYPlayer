//
//  ViewController.swift
//  RongYaoTeamPrompt
//
//  Created by summer的Dad on 2018/6/23.
//  Copyright © 2018年 ZhuQiong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
     demo1()
        
    }

    
    func demo1()  {
        let myView = UIView()
        myView.backgroundColor = UIColor.white
        self.view.addSubview(myView)
        myView.snp.makeConstraints { (snp) in
            snp.edges.equalTo(self.view)
        }
       let prompot = RYPrompt.init(presentView: myView)
           prompot.showTitle(title: "敬请期待", duration: 3)
//        prompot._show()
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

