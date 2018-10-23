//
//  ARKitRecorder.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import ARKit
import AVFoundation

public class ARKitRecorder: NSObject {
    
    public enum ARKitRecorderError: Error {
        case noCameraPermission
        case noAudioPermission
        case movieGenerateFailed
    }
    
    let queue: DispatchQueue = DispatchQueue(label: "com.timers-inc.tfam.ARKitRecorder")
    
    private let renderer = SCNRenderer(device: nil, options: nil)
    
    private var isRecording: Bool = false
    
    let options: Options
    public init(options: Options) {
        self.options = options
        
        super.init()
    }
    
    lazy var movieRecorder = MovieRecorder(options: options)
    
    lazy var audioRecorder = try? AudioRecorder(url: options.audioURL)
    
    private func checkCameraAccessPermission(_ completion: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            completion(granted)
        }
    }
    
    private func checkMicrophoneAccessPermission(_ completion: @escaping (Bool) -> ()) {
        if AVAudioSession.sharedInstance().recordPermission != .granted {
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                completion(granted)
            })
        } else {
            completion(true)
        }
    }
    
    public typealias Completion = (URL?) -> ()
    
    public func start(with sceneView: ARSCNView, completion: @escaping (Error?) -> ()) {
        guard !isRecording else { return }
        
        checkCameraAccessPermission { (granted) in
            guard granted else {
                completion(ARKitRecorderError.noCameraPermission)
                return
            }
            
            self.checkMicrophoneAccessPermission({ (granted) in
                guard granted else {
                    completion(ARKitRecorderError.noAudioPermission)
                    return
                }
                
                do {
                    try self._start(with: sceneView)
                    completion(nil)
                } catch {
                    completion(error)
                }
            })
        }
    }
    
    private func _start(with sceneView: ARSCNView) throws {
        renderer.scene = sceneView.scene
        try movieRecorder.start()
        audioRecorder?.start()
        isRecording = true
    }
    
    public func cancel() {
        guard isRecording else { return }
        movieRecorder.cancel()
        try? audioRecorder?.cancel()
    }
    
    public func finish(_ completion: @escaping Completion) {
        guard isRecording else { return }
        movieRecorder.finish {
            self.audioRecorder?.finish {
                let movieGenerator = MovieGenerator(movieURL: self.options.movieURL, audioURL: self.options.audioURL)
                do {
                    try movieGenerator.perform(with: self.options.videoURL, completion: {
                        completion(self.options.videoURL)
                    })
                } catch {
                    completion(nil)
                }
                
                self.isRecording = false
            }
        }
    }
    
    public func append(with rendered: SCNSceneRenderer, at time: TimeInterval) {
        movieRecorder.currentTime = time
        queue.async {
            guard self.isRecording else { return }
            let image = self.renderer.snapshot(atTime: time, with: self.options.size, antialiasingMode: .none)
            guard let pixelBufferPool = self.movieRecorder.adaptor?.pixelBufferPool else {
                return }
            guard let pixelBuffer = image.cvPixelBuffer(with: self.options.size, and: pixelBufferPool) else {
                return
            }
            self.movieRecorder.append(pixelBuffer: pixelBuffer, time: CMTimeMakeWithSeconds(time, preferredTimescale: 1000000))
        }
    }
}
