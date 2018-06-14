//
//  RYTestViewController.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation

class RYTestViewController: UIViewController {
    
    var player: RongYaoTeamPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        let videoURL = URL.init(string: "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4")
        player = RongYaoTeamPlayer.init()
        player?.ry_URL = videoURL
        player?.ry_delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension RYTestViewController: RongYaoTeamPlayerDelegate {
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey: RongYaoTeamPlayerPropertyKey) {
        
    }
    
    func player(_ player: RongYaoTeamPlayer, prepareToPlay URL: URL?) {
        print("准备播放: ", URL!, Thread.current, "\n")
    }
    
    func playerCurrentTimeDidChange(_ player: RongYaoTeamPlayer) {
        print("当前时间: ", player.ry_currentTime, Thread.current, "\n")
    }
    
    func playerDurationDidChange(_ player: RongYaoTeamPlayer) {
        print("播放持续时间: ", player.ry_duration, Thread.current, "\n")
    }
    
    func playerBufferLoadedTimeDidChange(_ player: RongYaoTeamPlayer) {
        print("当前缓冲: ", player.ry_bufferLoadedTime, Thread.current, "\n")
    }
    
    func playerStatusDidChange(_ player: RongYaoTeamPlayer) {
        print("播放状态改变: ", player.ry_state, Thread.current, "\n")
    }
    
    func playerPlaybackBufferEmpty(_ player: RongYaoTeamPlayer) {
        print("缓冲为空", Thread.current, "\n")
    }
    
    func playerPlaybackBufferFull(_ player: RongYaoTeamPlayer) {
        print("缓冲已满", Thread.current, "\n")
    }
    
    func playerDidLoadPresentationSize(_ player: RongYaoTeamPlayer) {
//        print("视频size: %@", player.p)
    }
    
    func playerDidPlayToEndTime(_ player: RongYaoTeamPlayer) {
        print("播放完毕", Thread.current, "\n")
    }
}
