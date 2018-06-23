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
                     interval: TimeInterval,
                     savePath: RongYaoTeamFileURL,
                     exportProgress: @escaping (_ progress: Float)->(),
                     completionHandler: @escaping (_ export: RongYaoTeamPlayerExport, _ GIF: UIImage, _ thumbnailImage: UIImage?)->(),
                     failureHanlder: @escaping (_ export: RongYaoTeamPlayerExport, _ error: Error?)->()) {
        if ( GIFGenerator != nil ) {
            GIFGenerator?.cancelAllCGImageGeneration()
        }
        
        var count = Int(ceil(duration/interval))
        var times = Array<NSValue>()
        for i in 0...count {
            times.append(NSValue.init(time: CMTimeMakeWithSeconds(Float64(start + TimeInterval(i) * interval), Int32(NSEC_PER_SEC))))
        }
        GIFGenerator = AVAssetImageGenerator.init(asset: self.asset)
        GIFGenerator?.appliesPreferredTrackTransform = true
        GIFGenerator?.requestedTimeToleranceBefore = kCMTimeZero
        GIFGenerator?.requestedTimeToleranceAfter = kCMTimeZero
        GIFGenerator?.maximumSize = maximumSize
        
        let GIFCreator = SJGIFCreator.init(savePath, count: count)
        let all = count
    
        GIFGenerator?.generateCGImagesAsynchronously(forTimes: times, completionHandler: { [weak self] (requestedTime, imageRef, actualTime, result, error) in
            guard let `self` = self else { return }
            switch result {
            case .succeeded:
                GIFCreator.add(imageRef!)
                DispatchQueue.main.async {
                    exportProgress(1.0 - Float(count) / Float(all))
                }
                count = count - 1
                if ( count != 0 ) { return }
                GIFCreator.finalize()
                guard let data = try? Data.init(contentsOf: savePath) else {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        failureHanlder(self, error)
                    }
                    return
                }
                let image = self.getImage(data: data, scale: UIScreen.main.scale)
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    exportProgress(1.0)
                    completionHandler(self, image!, GIFCreator.firstImage!)
                }
            case .failed:
                self.GIFGenerator?.cancelAllCGImageGeneration()
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    failureHanlder(self, error)
                }
            default: break
            }
        })
    }
    
    /**
     ref: YYKit
     github: https://github.com/ibireme/YYKit/blob/4e1bd1cfcdb3331244b219cbd37cc9b1ccb62b7a/YYKit/Base/UIKit/UIImage%2BYYAdd.m#L25
     UIImage(YYAdd)
     */
    private func getImage(data: Data, scale: CGFloat) -> UIImage? {
        guard let `source` = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        if ( count <= 1 ) {
            return UIImage.init(data: data, scale: scale)
        }
        
        
        var frames: [Int] = [Int]()
        let oneFrameTime = 1.0 / 50.0 // 50 fps
        var totalTime: TimeInterval = 0.0
        var totalFrame: Int = 0
        var gcdFrame: Int = 0
        
        for i in 0...count {
            let delay = _yy_CGImageSource(source, getGIFFrameDelayAtIndex: i)
            totalTime = totalTime + delay
            var frame = lrint(delay / oneFrameTime)
            if ( frame < 1 ) { frame = 1 }
            frames.append(frame)
            totalFrame = totalFrame + frame
            if ( i == 0 ) { gcdFrame = frame }
            else {
                var frame = frames[i]
                var tmp: Int = 0
                if ( frame < gcdFrame ) {
                    tmp = frame; frame = gcdFrame; gcdFrame = tmp;
                }
                while ( true ) {
                    tmp = frame % gcdFrame
                    if ( tmp == 0 ) { break }
                    frame = gcdFrame
                    gcdFrame = tmp
                }
            }
        }
        
        var array = Array<UIImage>()
        for i in 0...count {
            guard let imageRef = CGImageSourceCreateImageAtIndex(source, i, nil) else { return nil }
            let width = imageRef.width
            let height = imageRef.height
            if ( width == 0 || height == 0 ) { return nil }
            
            let alphaInfo = UInt8(imageRef.alphaInfo.rawValue) & UInt8(CGBitmapInfo.alphaInfoMask.rawValue)
            var hasAlpha = false
            if ( alphaInfo == UInt8(CGImageAlphaInfo.premultipliedLast.rawValue) ||
                 alphaInfo == UInt8(CGImageAlphaInfo.premultipliedFirst.rawValue) ||
                 alphaInfo == UInt8(CGImageAlphaInfo.last.rawValue) ||
                 alphaInfo == UInt8(CGImageAlphaInfo.first.rawValue) ) {
                hasAlpha = true
            }

            // BGRA8888 (premultiplied) or BGRX8888
            // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
            var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
            bitmapInfo |= hasAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue
            let space = CGColorSpaceCreateDeviceRGB()
            guard let context = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: bitmapInfo) else { return nil }
            
            context.draw(imageRef, in: CGRect.init(x: 0, y: 0, width: width, height: height)) // decode
            guard let decoded = context.makeImage() else { return nil }
            let image: UIImage = UIImage.init(cgImage: decoded, scale: scale, orientation: .up)
            let max = frames[i] / gcdFrame
            for _ in 0...max {
                array.append(image)
            }
        }
        return UIImage.animatedImage(with: array, duration: totalTime)
    }
    
    /**
     ref: YYKit
     github: https://github.com/ibireme/YYKit/blob/4e1bd1cfcdb3331244b219cbd37cc9b1ccb62b7a/YYKit/Base/UIKit/UIImage%2BYYAdd.m#L25
     UIImage(YYAdd)
     */
    private func _yy_CGImageSource(_ source: CGImageSource, getGIFFrameDelayAtIndex index: Int) -> TimeInterval {
        var delay: TimeInterval = 0.1
        guard let dic = CGImageSourceCopyPropertiesAtIndex(source, index, nil) else { return delay }
        guard let dicGIF = (dic as Dictionary)[kCGImagePropertyGIFDictionary] else { return delay }
        guard let num = dicGIF[kCGImagePropertyGIFUnclampedDelayTime] else { return delay }
        var n = num as! NSNumber
        if ( n.floatValue <= .ulpOfOne ) {
            n = dicGIF[kCGImagePropertyGIFDelayTime] as! NSNumber
        }
        delay = n.doubleValue
        if ( delay < 0.02 ) { return 0.1 }
        return delay
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
    
    @discardableResult
    fileprivate func finalize() -> Bool {
        return CGImageDestinationFinalize(destination)
    }
    
    private let savePath: URL
    private let count: Int
    private var destination: CGImageDestination
    private let frameProperties: [CFString:Any]
}
