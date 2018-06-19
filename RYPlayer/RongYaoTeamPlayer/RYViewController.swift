//
//  RYViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import SJSlider

class RYViewController: UIViewController {
    
    var player: RongYaoTeamPlayer?
    
    var slider: SJSlider?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        player = RongYaoTeamPlayer.init()
        player?.delegate = self

        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.view.addSubview(player!.view)
        player!.view.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(player!.view.snp.width).multipliedBy(9/16.0)
        }
        
        slider = SJSlider.init()
        slider?.delegate = self
        slider?.enableBufferProgress = true
        slider?.backgroundColor = UIColor.purple
        self.view.addSubview(slider!)
        slider?.snp.makeConstraints({ (make) in
            make.top.equalTo(player!.view.snp.bottom).offset(20)
            make.leading.equalTo(self.view).offset(12)
            make.trailing.equalTo(self.view).offset(-12)
            make.height.equalTo(40)
        })

        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override var shouldAutorotate: Bool {
        return false
    }

    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    
    @IBAction func initalize(_ sender: Any) {
        let videoURL = URL.init(string: "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4")
//        player?.asset = RongYaoTeamPlayerAsset.init(videoURL!)
        player?.asset = RongYaoTeamPlayerAsset.init(videoURL!, specifyStartTime: 20)
    }
    
    @IBAction func play(_ sender: Any) {
        player?.play()
    }
    
    @IBAction func pause(_ sender: Any) {
        player?.pause()
    }
    
    @IBAction func replay(_ sender: Any) {
        player?.replay()
    }
    
    @IBAction func stop(_ sender: Any) {
        player?.stop()
        
    }
}

extension RYViewController: SJSliderDelegate {
    func sliderWillBeginDragging(_ slider: SJSlider) {
        
    }
    
    func sliderDidDrag(_ slider: SJSlider) {
    
    }
    
    func sliderDidEndDragging(_ slider: SJSlider) {
        guard let `assetProperties` = player!.assetProperties else { return }
        player?.seekToTime(TimeInterval(slider.value) * assetProperties.duration, completionHandler: { (player, _) in })
    }
}

extension RYViewController: RongYaoTeamPlayerDelegate {
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey key: RongYaoTeamPlayerPropertyKey) {
        if ( key == RongYaoTeamPlayerPropertyKey.currentTime ) {
            if ( slider!.isDragging ) { return }
            slider!.value = CGFloat(player.assetProperties!.currentTime / player.assetProperties!.duration)
            print("--")
        }
        else if ( key == RongYaoTeamPlayerPropertyKey.bufferLoadedTime ) {
            slider?.bufferProgress = CGFloat(player.assetProperties!.bufferLoadedTime / player.assetProperties!.duration)
        }
    }
}
