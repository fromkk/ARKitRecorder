//
//  UIImage+cvPixelBuffer.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import UIKit
import CoreVideo

extension UIImage {
    
    func cvPixelBuffer(with size: CGSize, and pixelBufferPool: CVPixelBufferPool) -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        var maybePixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &maybePixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            else {
                return nil
        }
        guard let cgImage = cgImage else { return nil }
        let drawRect = CGRect(origin: .zero, size: size)
        context.clear(drawRect)
        context.draw(cgImage, in: drawRect)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        return pixelBuffer
    }
    
}
