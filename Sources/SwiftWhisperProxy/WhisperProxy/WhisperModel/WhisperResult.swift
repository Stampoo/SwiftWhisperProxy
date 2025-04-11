//
//  WhisperResult.swift
//  SwiftWhisperProxy
//
//  Created by Илья Князьков on 09.04.2025.
//

public enum WhisperResult: Sendable {

    case success(_ recognitionResult: WhisperRecognizeResult)
    case progressDidChanged(_ progress: Double)

}

// MARK: - State

public extension WhisperResult {

    func get() throws -> WhisperRecognizeResult {
        guard case let .success(recognitionResult) = self else {
            throw BaseError(description: "Recognition result was not found")
        }

        return recognitionResult
    }

    var isDone: Bool {
        switch self {
        case .success:
            return true
        case .progressDidChanged:
            return false
        }
    }

}
