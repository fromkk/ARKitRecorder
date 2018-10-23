//
//  MovieRecorder.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import Foundation
import AVFoundation

class MovieRecorder: NSObject {
    
    var writer: AVAssetWriter?
    
    var input: AVAssetWriterInput?
    
    var adaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    var currentTime: TimeInterval = 0.0
    
    let options: ARKitRecorder.Options
    init(options: ARKitRecorder.Options) {
        self.options = options
        
        super.init()
        
        setup()
    }
    
    private func makeInput() -> AVAssetWriterInput {
        return AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
            AVVideoCodecKey: options.codec,
            AVVideoWidthKey: options.size.width,
            AVVideoHeightKey: options.size.height,
            ])
    }
    
    private func makeAdaptor(with input: AVAssetWriterInput) -> AVAssetWriterInputPixelBufferAdaptor {
        return AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: options.size.width,
            kCVPixelBufferHeightKey as String: options.size.height,
            ])
    }
    
    private var isSetup: Bool = false
    private func setup() {
        guard !isSetup else { return }
        defer { isSetup = true }
        
        do {
            try makeDirectoryIfNeeded(at: options.movieURL)
            
            let input = makeInput()
            self.adaptor = makeAdaptor(with: input)
            self.input = input
            
            try resetWriter()
        } catch {
            fatalError("AVAssetWriter initialize failed with error: \(error)")
        }
    }
    
    private func resetWriter() throws {
        writer = try AVAssetWriter(outputURL: options.movieURL, fileType: options.fileType)
        writer?.movieFragmentInterval = CMTime.invalid
        
        guard let input = self.input, writer?.canAdd(input) ?? false else { return }
        writer?.add(input)
    }
    
    func start() throws {
        try resetWriter()
        writer?.startWriting()
        writer?.startSession(atSourceTime: CMTimeMakeWithSeconds(currentTime, preferredTimescale: 1000000))

    }
    
    func append(pixelBuffer: CVPixelBuffer, time: CMTime) {
        guard input?.isReadyForMoreMediaData ?? false else { return }
        adaptor?.append(pixelBuffer, withPresentationTime: time)
    }
    
    func cancel() {
        writer?.cancelWriting()
    }
    
    func finish(_ completion: @escaping () -> ()) {
        input?.markAsFinished()
        writer?.finishWriting {
            completion()
        }
    }
    
    private func makeDirectoryIfNeeded(at url: URL) throws {
        let path = url.pathWithoutFilename
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: path) else { return }
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
}
