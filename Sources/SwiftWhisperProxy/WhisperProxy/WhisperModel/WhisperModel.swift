//
//  WhisperModel.swift
//  SwiftWhisperProxy
//
//  Created by Ilia Knyazkov on 21.03.2025.
//

import Foundation

public struct WhisperModel: Sendable {

    let path: URL

    public init(path: URL) {
        self.path = path
    }

    public init(stringPath: String) {
        self.init(path: URL(fileURLWithPath: stringPath))
    }

}
