//
//  WhisperParameter.swift
//  SwiftWhisperProxy
//
//  Created by Илья Князьков on 16.04.2025.
//

import whisper

public struct WhisperParameter<Value> {

    // MARK: - Internal property

    private(set) var value: Value

    public static func rawValue(_ value: Value) -> WhisperParameter<Value> {
        return WhisperParameter(value: value)
    }

}

