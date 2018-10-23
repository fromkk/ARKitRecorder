//
//  AudioRecorder.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject {
    
    var audioRecorder: AVAudioRecorder?
    
    let url: URL
    init(url: URL) throws {
        self.url = url
        super.init()
        
        try setup()
    }
    
    private var isSetup: Bool = false
    private func setup() throws {
        guard !isSetup else { return }
        defer { isSetup = true }
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [])
        try session.setActive(true, options: [])
        
        let settings: [String: Any] = [
            AVFormatIDKey: UInt(kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0,
        ]
        
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
    }
    
    func start() {
        guard !(audioRecorder?.isRecording ?? false) else { return }
        
        audioRecorder?.record()
    }
    
    func finish(_ completion: @escaping () -> ()) {
        audioRecorder?.stop()
        completion()
    }
    
    func cancel() throws {
        audioRecorder?.stop()
        try clearAudioFile()
    }
    
    private func clearAudioFile() throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }
    
}
