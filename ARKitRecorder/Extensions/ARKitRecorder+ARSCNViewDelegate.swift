//
//  ARKitRecorder+ARSCNViewDelegate.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import Foundation
import ARKit

extension ARKitRecorder: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        append(with: renderer, at: time)
    }
    
}
