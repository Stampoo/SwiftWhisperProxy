//
//  WhisperProxyImplementation.swift
//  SwiftWhisperProxy
//
//  Created by Илья Князьков on 09.04.2025.
//

import whisper
import Foundation
import AVFoundation

final class WhisperProxyImplementation: @unchecked Sendable, WhisperProxy {

    // MARK: - Private properties

    private var context: OpaquePointer
    private let model: WhisperModel
    private let operationQueue = DispatchQueue(label: "com.whisper_proxy.operation.queue")
    private var inProgress: Bool = false
    private var currentContinuation: AsyncThrowingStream<WhisperResult, Error>.Continuation?
    private var parameters: WhisperParameters

    // MARK: - Initialization

    required init(model: WhisperModel) throws {
        let context = model.path.relativePath.withCString { cString in
            whisper_init_from_file_with_params(cString, whisper_context_params())
        }
        
        guard let context = context else {
            throw BaseError(description: "Filed to initialize whisper context with model URL: \(model.path.relativePath)")
        }

        self.context = context
        self.model = model
        self.parameters = WhisperParameters()
    }

    convenience init(model: WhisperModel, parameters: WhisperParameters) throws {
        try self.init(model: model)
        self.parameters = parameters
    }

    deinit {
        whisper_free(context)
    }

    // MARK: - WhisperProxy

    func recognize(from audioFrames: [Float]) -> AsyncThrowingStream<WhisperResult, Error> {
        return AsyncThrowingStream { [weak self] continuation in
            guard let self = self else { return }

            self.currentContinuation = continuation
            self.operationQueue.async {
                do {
                    let recognizedText = try self.recognize(audioFrames: audioFrames)
                    let recognitionResult = WhisperRecognizeResult(recognizedText: recognizedText)
                    let result = WhisperResult.success(recognitionResult)
                    continuation.yield(result)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func recognize(from audioFileURL: URL, converter: AudioConverter) throws -> AsyncThrowingStream<WhisperResult, Error> {
        let audioFrames = try converter.convertWavFileTo16kHzPCMArray(from: audioFileURL)
        return recognize(from: audioFrames)
    }

    func recognize(from audioFrames: [Float]) async throws -> WhisperRecognizeResult {
        for try await result in recognize(from: audioFrames) {
            if case let .success(recognitionResult) = result {
                return recognitionResult
            }
        }

        throw BaseError(description: "Recognition was not found")
    }

    func recognize(from audioFileURL: URL, converter: AudioConverter) async throws -> WhisperRecognizeResult {
        for try await result in try recognize(from: audioFileURL, converter: converter) {
            if case let .success(recognitionResult) = result {
                return recognitionResult
            }
        }

        throw BaseError(description: "Recognition was not found")
    }

    func recognize(from audioData: Data, converter: AudioConverter) async throws -> AsyncThrowingStream<WhisperResult, any Error> {
        let audioFrames = try await converter.convertBufferTo16kHzPCMArray(from: audioData)
        return recognize(from: audioFrames)
    }
}

// MARK: - Private properties

private extension WhisperProxyImplementation {

    func recognize(audioFrames: [Float]) throws -> String {
        guard !audioFrames.isEmpty else {
            throw BaseError(description: "Audio frames is empty")
        }

        guard !inProgress else {
            throw BaseError(description: "Whisper currently in progress")
        }

        let whisperInstancePointer = Unmanaged.passUnretained(self).toOpaque()

        guard let langPointer = parameters.langPointer else {
            throw BaseError(description: "Can't find language pointer")
        }

        var parameters = parameters.whisperParameters
        parameters.language = UnsafePointer(langPointer)

        setProgresCallback(to: whisperInstancePointer, in: &parameters)

        inProgress = true

        let audioFramesPointer = audioFrames.withUnsafeBufferPointer { $0.baseAddress }

        guard let audioFramesPointer = audioFramesPointer else {
            throw BaseError(description: "Can't convert audio frames to cPointers")
        }

        let countOfAudioFrames = Int32(audioFrames.count)
        let result = whisper_full(context, parameters, audioFramesPointer, countOfAudioFrames)

        guard result >= .zero else {
            throw BaseError(description: "Recognition failed, error code: \(result)")
        }

        let countOfSegments = whisper_full_n_segments(context)
        let recognizedText = extractRecognizedTextFromContext(context: context, countOfSegments: countOfSegments)

        inProgress = false

        return recognizedText
    }

    func setProgresCallback(to handler: UnsafeMutableRawPointer, in parameters: inout whisper_full_params) {
        parameters.progress_callback = { (_, _, progress: Int32, userData: UnsafeMutableRawPointer?) in
            guard let whisperInstancePointer = userData else { return }
            let whisperInstance = Unmanaged<WhisperProxyImplementation>
                .fromOpaque(whisperInstancePointer)
                .takeUnretainedValue()

            let currentProgress = Double(progress)
            whisperInstance.notifyAboutProgress(currentProgress)
        }

        parameters.progress_callback_user_data = handler
    }

    func notifyAboutProgress(_ progress: Double) {
        currentContinuation?.yield(.progressDidChanged(progress))
    }

    func extractRecognizedTextFromContext(context: OpaquePointer, countOfSegments: Int32) -> String {
        var recognizedText: String = ""

        for index in 0..<countOfSegments {
            let cString = whisper_full_get_segment_text(context, index)

            guard let cString = cString else {
                continue
            }

            let segmentText = String(cString: cString)

            guard !segmentText.isEmpty else {
                continue
            }

            let resultChunk = index != countOfSegments - 1 ? segmentText + " " : segmentText + ""
            recognizedText += resultChunk
        }

        return recognizedText.trimmingCharacters(in: .whitespaces)
    }

}

// MARK: - Constants

private extension String {
    static let autoDetectionLanguage: Self = "auto"
}

// MARK: - Initialziation

public func NewWhisperProxy(model: WhisperModel, parameters: WhisperParameters) throws -> WhisperProxy {
    return try WhisperProxyImplementation(model: model, parameters: parameters)
}
