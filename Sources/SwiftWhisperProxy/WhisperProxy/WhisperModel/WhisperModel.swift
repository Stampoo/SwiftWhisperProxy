//
//  WhisperModel.swift
//  SwiftWhisperProxy
//
//  Created by Ilia Knyazkov on 21.03.2025.
//

import Foundation

public struct WhisperModel: Sendable {

    let path: URL
    let language: Language

    public init(path: URL, language: Language = .auto) {
        self.path = path
        self.language = language
    }

    public init(stringPath: String, language: Language = .auto) {
        self.init(path: URL(fileURLWithPath: stringPath), language: language)
    }

}

// MARK: - Language

public extension WhisperModel {

    enum Language: String, Sendable {
        case auto
        case en
        case ru
    }

}
