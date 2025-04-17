//
//  WhisperParameters.swift
//  SwiftWhisperProxy
//
//  Created by Илья Князьков on 16.04.2025.
//

import whisper
import Foundation

@dynamicMemberLookup
public final class WhisperParameters {

    // MARK: - Internal properties

    public var whisperParameters: whisper_full_params
    public var lang: WhisperParameter = .rawValue("auto") {
        didSet {
            free(langPointer)
            langPointer = strdup(lang.value)
        }
    }

    private(set) var langPointer: UnsafeMutablePointer<Int8>?

    // MARK: - Initialization

    public init(
        whisperParameters: whisper_full_params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY),
        _ parametersBlock: (_ parameters: WhisperParameters) -> Void = { _ in }
    ) {
        self.whisperParameters = whisperParameters
        parametersBlock(self)
        self.langPointer = strdup(lang.value)
    }

    public init() {
        whisperParameters = whisper_full_default_params(WHISPER_SAMPLING_GREEDY)
        self.langPointer = strdup(lang.value)
    }

    // MARK: - dynamicMemberLookup

    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<whisper_full_params, Value>) -> Value {
        get {
            return whisperParameters[keyPath: keyPath]
        }

        set {
            whisperParameters[keyPath: keyPath] = newValue
        }
    }

}
