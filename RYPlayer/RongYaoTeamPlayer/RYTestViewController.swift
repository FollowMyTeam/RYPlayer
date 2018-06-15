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
import SJSlider

class RYTestViewController: UIViewController {
    
    var player: RongYaoTeamPlayer?
    
    var slider: SJSlider?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        player = RongYaoTeamPlayer.init()
        player?.ry_delegate = self

        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.view.addSubview(player!.ry_view)
        player!.ry_view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(player!.ry_view.snp.width).multipliedBy(9/16.0)
        }
        
        slider = SJSlider.init()
        slider?.delegate = self
        slider?.enableBufferProgress = true
        slider?.backgroundColor = UIColor.purple
        self.view.addSubview(slider!)
        slider?.snp.makeConstraints({ (make) in
            make.top.equalTo(player!.ry_view.snp.bottom).offset(20)
            make.leading.equalTo(self.view).offset(12)
            make.trailing.equalTo(self.view).offset(-12)
            make.height.equalTo(40)
        })

        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func initalize(_ sender: Any) {
        let videoURL = URL.init(string: "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4")
//        player?.ry_asset = RongYaoTeamPlayerAsset.init(videoURL!)
        player?.ry_asset = RongYaoTeamPlayerAsset.init(videoURL!, specifyStartTime: 20)
    }
    
    @IBAction func play(_ sender: Any) {
        player?.ry_play()
    }
    
    @IBAction func pause(_ sender: Any) {
        player?.ry_pause()
    }
    
    @IBAction func replay(_ sender: Any) {
        player?.ry_replay()
    }
    
    @IBAction func stop(_ sender: Any) {
        player?.ry_stop()
    }
}

extension RYTestViewController: SJSliderDelegate {
    func sliderWillBeginDragging(_ slider: SJSlider) {
        
    }
    
    func sliderDidDrag(_ slider: SJSlider) {
    
    }
    
    func sliderDidEndDragging(_ slider: SJSlider) {
        guard let `ry_assetProperties` = player!.ry_assetProperties else { return }
        player?.ry_seekToTime(TimeInterval(slider.value) * ry_assetProperties.ry_duration, completionHandler: { (player, _) in })
    }
}

extension RYTestViewController: RongYaoTeamPlayerDelegate {
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey key: RongYaoTeamPlayerPropertyKey) {
        if ( key == RongYaoTeamPlayerPropertyKey.ry_currentTime ) {
            if ( slider!.isDragging ) { return }
            slider!.value = CGFloat(player.ry_assetProperties!.ry_currentTime / player.ry_assetProperties!.ry_duration)
            print("--")
        }
        else if ( key == RongYaoTeamPlayerPropertyKey.ry_bufferLoadedTime ) {
            slider?.bufferProgress = CGFloat(player.ry_assetProperties!.ry_bufferLoadedTime / player.ry_assetProperties!.ry_duration)
        }
    }
}
