//
//  RYTestViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class RYTestViewController: UIViewController {
    
    var player: RongYaoTeamPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        let videoURL = URL.init(string: "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4")
        player = RongYaoTeamPlayer.init()
        player?.ry_asset = RongYaoTeamPlayerAsset.init(videoURL!)
        player?.ry_delegate = self

        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.view.addSubview(player!.ry_view)
        player!.ry_view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(player!.ry_view.snp.width).multipliedBy(9/16.0)
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension RYTestViewController: RongYaoTeamPlayerDelegate {
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey Key: RongYaoTeamPlayerPropertyKey) {
    }
}
