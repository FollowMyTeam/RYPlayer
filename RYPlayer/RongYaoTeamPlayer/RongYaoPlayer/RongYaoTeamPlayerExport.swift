//
//  RongYaoTeamPlayerExport.swift
//  RongYaoTeamPlayer
//
//  Created by BlueDancer on 2018/6/19.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import ImageIO


/// 导出
/// - 截屏
/// - 导出片段视频
/// - 导出片段GIF
public class RongYaoTeamPlayerExport {
    public init(_ asset: AVAsset, _ player: AVPlayer) {
        self.asset = asset
        self.player = player
    }
    
    deinit {
        screenshotGenerator?.cancelAllCGImageGeneration()
        exportSession?.cancelExport()
        exportProgressRefreshTimer?.invalidate()
    }
    
// MARK: private
    private var asset: AVAsset
    private var player: AVPlayer
    
    // screenshot
    private var screenshotGenerator: AVAssetImageGenerator?
    
    // export
    private var exportSession: AVAssetExportSession?
    private var exportProgressRefreshTimer: Timer?
    
    // GIF
    private var GIFGenerator: AVAssetImageGenerator?
}

public extension RongYaoTeamPlayerExport {
    func screenshot() -> UIImage? {
        return screenshot(self.player.currentTime())
    }
    
    func screenshot(_ time: TimeInterval) -> UIImage? {
        return screenshot(CMTimeMakeWithSeconds(Float64(time), Int32(NSEC_PER_SEC)))
    }
    
    func screenshot(_ time: CMTime) -> UIImage? {
        let generator = AVAssetImageGenerator.init(asset: self.asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = kCMTimeZero
        generator.requestedTimeToleranceAfter = kCMTimeZero
        var t = time
        guard let `imgRef` = try? generator.copyCGImage(at: time, actualTime: UnsafeMutablePointer(&t)) else {
            return nil
        }
        let image = UIImage.init(cgImage: imgRef)
        return image
    }
    
    func screenshot(_ time: TimeInterval, size: CGSize = .zero, completionHandler: @escaping (UIImage?)->()) {
        screenshot(CMTimeGetSeconds(CMTimeMakeWithSeconds(Float64(time), Int32(NSEC_PER_SEC))), size: size, completionHandler: completionHandler)
    }
    
    func screenshot(_ time: CMTime, size: CGSize = .zero, completionHandler: @escaping (UIImage?)->()) {
        if ( screenshotGenerator == nil ) {
            let generator = AVAssetImageGenerator.init(asset: self.asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = kCMTimeZero
            generator.requestedTimeToleranceAfter = kCMTimeZero
            screenshotGenerator = generator
        }
        else {
            screenshotGenerator?.cancelAllCGImageGeneration()
        }
        
        screenshotGenerator?.generateCGImagesAsynchronously(forTimes: [NSValue.init(time: time)], completionHandler: { (requestedTime, imageRef, actualTime, result, error) in
            switch result {
            case .succeeded:
                completionHandler(UIImage.init(cgImage: imageRef!))
            case .cancelled:
                break
            case .failed:
                completionHandler(nil)
            }
        })
    }
}

public extension RongYaoTeamPlayerExport {
    func export(start: TimeInterval,
                duration: TimeInterval,
                presentName: String = AVAssetExportPresetMediumQuality,
                exportProgress: @escaping (_ progress: Float)->(),
                completionHandler: @escaping (_ export: RongYaoTeamPlayerExport, _ sandboxAsset: AVAsset, _ fileURL: URL, _ thumbnailImage: UIImage?)->(),
                failureHanlder: @escaping (_ export: RongYaoTeamPlayerExport, _ error: Error?)->()) {
        
        if ( exportSession != nil ) {
            switch exportSession!.status {
            case .exporting:
                exportSession?.cancelExport()
                exportProgressRefreshTimer?.invalidate()
            default: break
            }
        }
        
        let compositionM = AVMutableComposition.init()
        let audioTrackM = compositionM.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoTrackM = compositionM.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let cutRange = CMTimeRangeMake(CMTimeMakeWithSeconds(Float64(start), Int32(NSEC_PER_SEC)), CMTimeMakeWithSeconds(Float64(start + duration), Int32(NSEC_PER_SEC)))
        let ori_audioTrack = asset.tracks(withMediaType: .audio).first
        let ori_videoTrack = asset.tracks(withMediaType: .video).first
        let exportURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("export.mp4")
        do {
            try audioTrackM?.insertTimeRange(cutRange, of: ori_audioTrack!, at: kCMTimeZero)
            try videoTrackM?.insertTimeRange(cutRange, of: ori_videoTrack!, at: kCMTimeZero)
            try FileManager.default.removeItem(at: exportURL)
        } catch {
            failureHanlder(self, error)
            return
        }
        
        exportSession = AVAssetExportSession.init(asset: asset, presetName: presentName)
        exportSession?.outputURL = exportURL
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.mp4
        
        exportProgressRefreshTimer = Timer.sj_timer(interval: 0.5, block: { [weak self] (timer) in
            guard let `self` = self else { timer.invalidate(); return }
            switch self.exportSession!.status {
            case .cancelled, .completed:
                timer.invalidate()
                return
            default: break
            }
            exportProgress(self.exportSession!.progress)
        }, repeats: true)
        
        RunLoop.main.add(exportProgressRefreshTimer!, forMode: RunLoopMode.commonModes)
        exportProgressRefreshTimer?.fireDate = Date.init(timeIntervalSinceNow: exportProgressRefreshTimer!.timeInterval)
        exportSession?.exportAsynchronously(completionHandler: { [weak self] in
            guard let `self` = self else { return }
            switch self.exportSession!.status {
            case .unknown, .waiting, .cancelled, .exporting: break
            case .completed:
                let image = self.screenshot(start)
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.exportProgressRefreshTimer?.invalidate()
                    exportProgress(1)
                    completionHandler(self, compositionM, exportURL, image!)
                }
            case .failed:
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    failureHanlder(self, self.exportSession!.error)
                }
            }
        })
    }
}

public extension RongYaoTeamPlayerExport {
    typealias RongYaoTeamFileURL = URL
    /// @interval The interval at which the image is captured, Recommended setting 0.1f.
    func generateGIF(start: TimeInterval,
                     duration: TimeInterval,
                     maximumSize: CGSize,
                     interval: Double,
                     savePath: RongYaoTeamFileURL,
                     exportProgress: @escaping (_ progress: Float)->(),
                     completionHandler: @escaping (_ export: RongYaoTeamPlayerExport, _ GIF: UIImage, _ thumbnailImage: UIImage?)->(),
                     failureHanlder: @escaping (_ export: RongYaoTeamPlayerExport, _ error: Error?)->()) {
        if ( GIFGenerator != nil ) {
            GIFGenerator?.cancelAllCGImageGeneration()
        }
        
        let count = Int(ceil(duration/interval))
// TODO: Next .... 回家
    }
}

// FIXME: CFRelease函数调不出来, 查看是否内存泄漏(待项目搭起来后)

fileprivate class SJGIFCreator {
    fileprivate var firstImage: UIImage?
    init(_ savePath: URL, count: Int) {
        self.savePath = savePath
        self.count = count
        try? FileManager.default.removeItem(at: savePath)
        destination = CGImageDestinationCreateWithURL(savePath as CFURL, kUTTypeGIF, count, nil)!
        let fileProperties: Dictionary = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFLoopCount:0]]
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        frameProperties = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFDelayTime:0.25]]
    }
    
    fileprivate func add(_ image: CGImage) {
        if ( firstImage == nil ) {
            firstImage = UIImage.init(cgImage: image)
        }
        CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
    }
    
    fileprivate func finalize() -> Bool {
        return CGImageDestinationFinalize(destination)
    }
    
    private let savePath: URL
    private let count: Int
    private var destination: CGImageDestination
    private let frameProperties: [CFString:Any]
}
