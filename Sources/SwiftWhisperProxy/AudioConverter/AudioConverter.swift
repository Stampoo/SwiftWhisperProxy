//
//  AudioConverter.swift
//  SwiftWhisperProxy
//
//  Created by Ilia Knyazkov on 10.04.2025.
//

import AVFoundation

public protocol AudioConverter: Sendable {

    /// Convert raw audio data to Audio data as 16-bit PCM suitable for Whisper
    /// - Parameters:
    ///   - audioData: Raw Audio data, received from server as example
    /// - Returns: PCM float array (16kHz, mono)
    func convertBufferTo16kHzPCMArray(from audioData: Data) async throws -> [Float]

    /// Convert audio file to audio data as 16-bit PCM  suitable for Whisper
    /// - Parameter url: ``URL`` to file
    /// - Returns: audio data as 16-bit PCM
    func convertWavFileTo16kHzPCMArray(from url: URL) throws -> [Float]

}
