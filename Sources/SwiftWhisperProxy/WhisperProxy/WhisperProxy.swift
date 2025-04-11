//
//  WhisperProxy 2.swift
//  SwiftWhisperProxy
//
//  Created by Илья Князьков on 09.04.2025.
//


import Foundation
import AVFoundation

public protocol WhisperProxy: Sendable {

    typealias AVAudioChannelCount = AVFoundation.AVAudioChannelCount
    
    /// Initialization
    /// - Parameter model: ``WhisperModel``
    /// - Warning: This operation may take some time depending on your hardware.
    /// - Warning: For ``CoreML``, your `*.mlmc` model must be in the same location as the general model.
    init(model: WhisperModel) throws

    /// Recognize audio from a PCM frames
    /// - Parameter audioFrames: audio PCM frames
    /// - Returns: ``WhisperResult``, which can return ``Error`` or `progress` or ``WhisperRecognizeResult``
    func recognize(from audioFrames: [Float]) -> AsyncThrowingStream<WhisperResult, Error>

    /// Recognize audio from a PCM frames
    /// - Parameter audioFrames: audio PCM frames
    /// - Returns: ``WhisperRecognizeResult`` Recognized text
    func recognize(from audioFrames: [Float]) async throws -> WhisperRecognizeResult

    /// Recognize audio from file
    /// - Parameter audioFileURL: ``URL`` at audio file
    /// - Parameter converter: ``AudioConverter`` for convert audio file to PCM frames
    /// - Returns: ``WhisperResult``, which can return ``Error`` or `progress` or ``WhisperRecognizeResult``
    func recognize(from audioFileURL: URL, converter: AudioConverter) throws -> AsyncThrowingStream<WhisperResult, Error>

    /// Recognize audio from file
    /// - Parameter audioFileURL: ``URL`` at audio file
    /// - Parameter converter: ``AudioConverter`` for convert audio file to PCM frames
    /// - Returns: ``WhisperRecognizeResult`` Recognized text
    func recognize(from audioFileURL: URL, converter: AudioConverter) async throws -> WhisperRecognizeResult

    /// Recognize audio from a raw audio data
    /// - Parameters:
    ///   - audioData: Raw audio data
    ///   - sampleRate: Sample rate of the audio data
    ///   - channels: Number of audio channels
    ///   - converter: converter: ``AudioConverter`` for convert audio file to PCM frames
    ///   - Returns: ``WhisperResult``, which can return ``Error`` or `progress` or ``WhisperRecognizeResult``
    func recognize(from audioData: Data, converter: AudioConverter) async throws -> AsyncThrowingStream<WhisperResult, Error>

}
