//
//  UtilsForTests.swift
//  SwiftWhisperProxy
//
//  Created by Ilia Knyazkov on 10.04.2025.
//

import Foundation
import SwiftWhisperProxy

enum UtilsForTests {

    static var audioFile: URL {
        let directoryPath = "/" + #filePath.split(separator: "/").dropLast(2).joined(separator: "/")
        let audiofilePath = URL(filePath: directoryPath + "/WhisperProxy/jfk.wav", directoryHint: .notDirectory)

        return audiofilePath
    }

    static var model: WhisperModel {
        let directoryPath = "/" + #filePath.split(separator: "/").dropLast(2).joined(separator: "/")
        let modelURL = URL(filePath: directoryPath + "/WhisperProxy/ggml-tiny.bin", directoryHint: .notDirectory)

        return WhisperModel(path: modelURL)
    }

}
