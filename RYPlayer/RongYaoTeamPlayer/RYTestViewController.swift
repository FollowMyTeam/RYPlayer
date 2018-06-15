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
    
    private let ry_devOperationsOfInitializing: [()->Void] = {
        return [()->Void]()
    }()
    
    private let ry_queue: OperationQueue = {
        let q = OperationQueue.init()
        q.name = "com.RongYaoTeam.player"
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    private enum RongYaoTeamPlayerOperation: String {
        case play = "play"
        case pause = "pause"
        case stop = "stop"
        case replay = "replay"
    }
    
    private let ry_playOperation: Operation = {
        let o = Operation.init()
        o.name = RongYaoTeamPlayerOperation.play.rawValue
        o.completionBlock = {
            print("play")
        }
        return o
    }()
    
    private let ry_pauseOperation: Operation = {
        let o = Operation.init()
        o.name = RongYaoTeamPlayerOperation.pause.rawValue
        o.completionBlock = {
            print("pause")
        }
        return o
    }()
    
    private let ry_stopOperation: Operation = {
        let o = Operation.init()
        o.name = RongYaoTeamPlayerOperation.stop.rawValue
        o.completionBlock = {
            print("stop")
        }
        return o
    }()
    
    private let ry_replayOperation: Operation = {
        let o = Operation.init()
        o.name = RongYaoTeamPlayerOperation.replay.rawValue
        o.completionBlock = {
            print("replay")
        }
        return o
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        let videoURL = URL.init(string: "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4")
        player = RongYaoTeamPlayer.init()
        player?.ry_asset = RongYaoTeamPlayerAsset.init(videoURL!)
        player?.ry_delegate = self

        
        ry_queue.isSuspended = true
        
        print(ry_playOperation.isReady)
        ry_queue.addOperation(ry_playOperation)
        ry_queue.addOperation(ry_pauseOperation)
        ry_queue.addOperation(ry_stopOperation)
        ry_queue.addOperation(ry_replayOperation)
        
        ry_queue.isSuspended = false
        
        enum RongYaoPlayerAssetState: Int {
            case unknown = 0, prepare, initialized
        }
        
        print(RongYaoPlayerAssetState.unknown.rawValue)
        print(RongYaoPlayerAssetState.prepare.rawValue)
        print(RongYaoPlayerAssetState.initialized.rawValue)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension RYTestViewController: RongYaoTeamPlayerDelegate {
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey Key: RongYaoTeamPlayerPropertyKey) {
        switch Key {
        case .ry_state:
            print(player.ry_state)
        default: break
        }
    }
}
