//
//  URL+Extensions.swift
//  ARKitRecorder
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import Foundation

extension URL {
    var pathWithoutFilename: String {
        let filename = lastPathComponent
        return path.replacingOccurrences(of: "/" + filename, with: "")
    }
}
