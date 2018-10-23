//
//  ARKitRecorder+Options.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import Foundation
import AVFoundation

extension ARKitRecorder {
    
    public class Options: NSObject {
        
        public var size: CGSize = CGSize(width: 1080.0, height: 1920.0)
        
        public var fileType: AVFileType = .m4v
        
        public var codec: AVVideoCodecType = AVVideoCodecType.h264
        
        var movieURL: URL = {
            let timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
            
            guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/com.timers-inc.tfam.ARKitRecorder/\(timestamp).m4v") else {
                fatalError("cache directory get failed")
            }
            return URL(fileURLWithPath: path)
        }()
        
        var audioURL: URL = {
            let timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
            
            guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/com.timers-inc.tfam.ARKitRecorder/\(timestamp).m4a") else {
                fatalError("cache directory get failed")
            }
            return URL(fileURLWithPath: path)
        }()
        
        public var videoURL: URL = {
            let timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
            
            guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/com.timers-inc.tfam.ARKitRecorder/\(timestamp).mp4") else {
                fatalError("cache directory get failed")
            }
            return URL(fileURLWithPath: path)
        }()
    }
    
}
