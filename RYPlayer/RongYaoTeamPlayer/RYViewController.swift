//
//  RYViewController.swift
//  RongYaoTeamPlayer
//
//  Created by 畅三江 on 2018/6/8.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import SJSlider

class RYViewController: UIViewController {
    
    deinit {
        #if DEBUG
        print("\(#function) - \(#line) - RYViewController")
        #endif
    }
    
    var playerBackgroundView: UIView!
    
    var player: RongYaoTeamPlayer?
    
    var slider: SJSlider?
    
    var gestureManager: RongYaoTeamGestureManager!
    
    var edgeControlLayer: RongYaoEdgeControlLayer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerBackgroundView = UIView.init(frame: .zero)
        view.addSubview(playerBackgroundView)
        playerBackgroundView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(playerBackgroundView.snp.width).multipliedBy(9/16.0)
        }

//        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        player = RongYaoTeamPlayer.init()
        player?.delegates.add(self)
        player?.view.rotationManager.delegate = self
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        playerBackgroundView.addSubview(player!.view)
        player!.view.snp.makeConstraints { (make) in
            make.edges.equalTo(player!.view.superview!)
        }
        
        gestureManager = RongYaoTeamGestureManager.init(target: player!.view.presentView)
        gestureManager.delegate = self
        
        edgeControlLayer = RongYaoEdgeControlLayer.init(frame: .zero)
        player?.view.presentView.addSubview(edgeControlLayer)
        edgeControlLayer.snp.makeConstraints { (make) in
            make.edges.equalTo(edgeControlLayer.superview!)
        }
        
        slider = SJSlider.init()
        slider?.delegate = self
        slider?.enableBufferProgress = true
        slider?.bufferProgressColor = UIColor.white
        slider?.backgroundColor = UIColor.purple
        self.view.addSubview(slider!)
        slider?.snp.makeConstraints({ (make) in
            make.top.equalTo(playerBackgroundView.snp.bottom)
            make.leading.trailing.equalTo(0)
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
//        let videoURL = URL.init(string: "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4")
        let videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")
//        player?.asset = RongYaoTeamPlayerAsset.init(videoURL!)
        player?.asset = RongYaoTeamPlayerAsset.init(videoURL!, specifyStartTime: 0)
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

extension RYViewController: RongYaoTeamRotationManagerDelegate {
    
    func triggerConditionForAutorotation(_ mgr: RongYaoTeamRotationManager) -> Bool {
        return true
    }
    
    func rotationManager(_ mgr: RongYaoTeamRotationManager, willRotateView isFullscreen: Bool) {

    }
    
    func rotationManager(_ mgr: RongYaoTeamRotationManager, didEndRotateView isFullscreen: Bool) {
        print("orientation: \(mgr.currentOrientation)")
    }
}

extension RYViewController: RongYaoTeamGestureManagerDelegate {
    func gestureManager(_ mgr: RongYaoTeamGestureManager, gestureShouldTrigger type: RongYaoTeamGestureManager.GestureType, location: CGPoint) -> Bool {
        return true
    }
    
    func triggerSingleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
    }
    
    func triggerDoubleTapGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
        guard let `player` = player else { return }
        
        if case RongYaoTeamPlayer.Status.paused(reason: .pause) = player.status {
            player.play()
        }
        else {
            player.pause()
        }
    }
    
    func triggerPinchGestureForGestureManager(_ mgr: RongYaoTeamGestureManager) {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
        guard let `player` = player else { return }
        
        if ( player.view.presentView.avVideoGravity == .resizeAspect ) {
            player.view.presentView.avVideoGravity = .resizeAspectFill
        }
        else {
            player.view.presentView.avVideoGravity = .resizeAspect
        }
    }
    
    func triggerPanGestureForGestureManager(_ mgr: RongYaoTeamGestureManager,
                                            state: RongYaoTeamGestureManager.PanGestureState,
                                            movingDirection: RongYaoTeamGestureManager.PanGestureMovingDirection,
                                            location: RongYaoTeamGestureManager.PanGestureLocation,
                                            translate: CGPoint) {
        #if DEBUG
        print("\(#function) - \(#line) - RongYaoTeamPlayer")
        #endif
        guard let `player` = player else { return }
        
        switch movingDirection {
        case .unknown: break
        case .horizontal:
            
            break
        case .vertical:
            break
        }
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
    func player(_ player: RongYaoTeamPlayer, valueDidChangeForKey key: RongYaoTeamPlayer.PropertyKey) {
        if ( key == RongYaoTeamPlayer.PropertyKey.currentTime ) {
            if ( slider!.isDragging ) { return }
            slider!.value = CGFloat(player.assetProperties!.currentTime / player.assetProperties!.duration)
        }
        else if ( key == RongYaoTeamPlayer.PropertyKey.bufferLoadedTime ) {
            slider?.bufferProgress = CGFloat(player.assetProperties!.bufferLoadedTime / player.assetProperties!.duration)
        }
    }
}
