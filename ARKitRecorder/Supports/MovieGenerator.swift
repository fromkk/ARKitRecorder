//
//  MovieGenerator.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/18.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import Foundation
import AVFoundation

class MovieGenerator: NSObject {
    
    let movieURL: URL
    let audioURL: URL
    init(movieURL: URL, audioURL: URL) {
        self.movieURL = movieURL
        self.audioURL = audioURL
        
        super.init()
    }
    
    func perform(with url: URL, completion: @escaping () -> ()) throws {
        let composition = AVMutableComposition()
        
        let movieAsset: AVAsset = AVAsset(url: movieURL)
        let audioAsset: AVAsset = AVAsset(url: audioURL)
        
        let duration = min(movieAsset.duration, audioAsset.duration)
        
        let movieTracks = movieAsset.tracks(withMediaType: .video)
        let audioTracks = audioAsset.tracks(withMediaType: .audio)
        
        if let movieTrack = movieTracks.first {
            let movieCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try movieCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: movieTrack, at: CMTime.zero)
        }
        
        if let audioTrack = audioTracks.first {
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: audioTrack, at: CMTime.zero)
        }
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1920x1080)
        exporter?.outputFileType = AVFileType.mp4
        exporter?.outputURL = url
        exporter?.exportAsynchronously {
            completion()
        }
    }
    
}
