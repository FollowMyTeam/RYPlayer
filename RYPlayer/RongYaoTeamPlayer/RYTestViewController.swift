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
    
    
    var player: RYPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let URL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        player = RYPlayer.init()
        player?.ry_URL = URL
        
        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension RYTestViewController: RYAVPlayerDelegate {
    func playerCurrentTimeDidChange(_ player: RYAVPlayer) {
        print(#function)
    }
}

extension RYTestViewController: RYAVPlayerItemDelegate {
    func playerItemDurationDidChange(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
    
    func playerItemCurrentBufferLoadedTimeDidChange(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
    
    func playerItemStatusDidChange(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
    
    func playerItemPlaybackBufferEmpty(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
    
    func playerItemPlaybackBufferFull(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
    
    func playerItemDidLoadPresentationSize(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
    
    func playerItemDidPlayToEndTime(_ playerItem: RYAVPlayerItem) {
        print(#function)
    }
}
