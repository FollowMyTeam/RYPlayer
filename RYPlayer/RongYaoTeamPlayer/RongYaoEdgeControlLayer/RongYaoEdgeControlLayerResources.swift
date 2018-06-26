//
//  RongYaoEdgeControlLayerResources.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/26.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit

public protocol RongYaoEdgeControlLayerResourcesDelegate {
    /// 资源加载完成
    func resources(_ r: RongYaoEdgeControlLayerResources, loadingIsCompleted type: RongYaoEdgeControlLayerResources.ViewResourcesType)
}

public class RongYaoEdgeControlLayerResources {
    
    init(delegate: (AnyObject & RongYaoEdgeControlLayerResourcesDelegate)) {
        self.delegate = delegate
        loadResources()
    }
    
    public var top: TopViewResources?
    
    public var left: LeftViewResources?
    
    public var bottom: BottomViewResources?
    
    public var right: RightViewResources?

    public weak var delegate: (AnyObject & RongYaoEdgeControlLayerResourcesDelegate)?
    
    private var bundle: Bundle!
}

fileprivate extension RongYaoEdgeControlLayerResources {
    
    func loadResources() {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            self.bundle = Bundle.init(path: Bundle.init(for: RongYaoEdgeControlLayerResources.self).path(forResource: "RongYaoEdgeControlLayer", ofType: "bundle")!)

            // Top
            DispatchQueue.global().async { [weak self] in
                guard let `self` = self else { return }
                let top = TopViewResources()
                top.backImage = self.image("sj_video_player_back")
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.top = top
                    self.delegate?.resources(self, loadingIsCompleted: .top)
                }
            }
            
            // Left
            DispatchQueue.global().async { [weak self] in
                guard let `self` = self else { return }
                let left = LeftViewResources()
                left.lockscreenImage = self.image("sj_video_player_lock")
                left.unlockscreenImage = self.image("sj_video_player_unlock")
                DispatchQueue.main.sync { [weak self] in
                    guard let `self` = self else { return }
                    self.left = left
                    self.delegate?.resources(self, loadingIsCompleted: .left)
                }
            }
            
            // Bottom
            DispatchQueue.global().async { [weak self] in
                guard let `self` = self else { return }
                let bottom = BottomViewResources()
                bottom.playImage = self.image("sj_video_player_play")
                bottom.pauseImage = self.image("sj_video_player_pause")
                bottom.fullscreenImage = self.image("sj_video_player_fullscreen")
                bottom.shrrinkscreenImage = self.image("sj_video_player_shrinkscreen")
                bottom.progressConfig = SliderConfig()
                DispatchQueue.main.sync { [weak self] in
                    guard let `self` = self else { return }
                    self.bottom = bottom
                    self.delegate?.resources(self, loadingIsCompleted: .bottom)
                }
            }

            // Right
            DispatchQueue.global().async { [weak self] in
                guard let `self` = self else { return }
                let right = RightViewResources()
                right.editImage = self.image("sj_video_player_edit")
                DispatchQueue.main.sync { [weak self] in
                    guard let `self` = self else { return }
                    self.right = right
                    self.delegate?.resources(self, loadingIsCompleted: .right)
                }
            }
        }
    }
    
    private func image(_ named: String) -> UIImage? {
        return UIImage.init(named: named, in: bundle, compatibleWith: nil)
    }
}

public extension RongYaoEdgeControlLayerResources {
    
    enum ViewResourcesType: Int {
        case top
        case left
        case bottom
        case right
    }
    
    
    class TopViewResources {
        public var backImage: UIImage?
    }
    
    class LeftViewResources {
        public var lockscreenImage: UIImage?
        public var unlockscreenImage: UIImage?
    }
    
    class BottomViewResources {
        public var playImage: UIImage?
        public var pauseImage: UIImage?
        public var fullscreenImage: UIImage?
        public var shrrinkscreenImage: UIImage?
        public var progressConfig: SliderConfig?
    }
    
    class RightViewResources {
        public var editImage: UIImage?
    }
    
    class SliderConfig {
        /// 轨道
        public var track: Track = Track()
       
        /// 拇指
        public var thumb: Thumb?
        
        public struct Track {
            /// 高度
            /// - default is 3.0
            public var height: CGFloat = 3
            /// 颜色
            /// - default is lightGray
            public var color: UIColor = .lightGray
            
            /// 轨迹颜色
            /// - default is orange
            public var traceColor:  UIColor = .orange
            
            /// 缓冲进度颜色
            /// - default is white
            public var bufferColor: UIColor = .white
        }
        
        public struct Thumb {
            /// 拇指大小
            /// - default is 0
            public var size: CGFloat = 0
            
            /// 拇指颜色
            public var color: UIColor?
            
            /// 拇指图片
            public var image: UIImage?
        }
    }
}
