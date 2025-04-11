//
//  DefaultAudioConverter.swift
//  SwiftWhisperProxy
//
//  Created by Ilia Knyazkov on 10.04.2025.
//

import AVFoundation

public struct DefaultAudioConverter: Sendable, AudioConverter {

    // MARK: - Private properties

    private let temporaryFilePath: URL
    private let operationQueue: DispatchQueue

    // MARK: - Initialization

    public init() {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        self.temporaryFilePath = temporaryDirectory.appendingPathComponent("temp_audio_file", conformingTo: .audio)
        self.operationQueue = DispatchQueue(
            label: "com.whisper_proxy.audio_converter.operation.queue",
            qos: .userInitiated,
            attributes: .concurrent
        )
    }

    // MARK: - AudioConverter

    public func convertBufferTo16kHzPCMArray(from audioData: Data) async throws -> [Float] {
        return try await withCheckedThrowingContinuation { continuation in
            operationQueue.async {
                do {
                    try audioData.write(to: temporaryFilePath)
                    let audioFrames = try convertWavFileTo16kHzPCMArray(from: temporaryFilePath)
                    try Data().write(to: temporaryFilePath)
                    continuation.resume(returning: audioFrames)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func convertWavFileTo16kHzPCMArray(from url: URL) throws -> [Float] {
        let inputFile = try AVAudioFile(forReading: url)

        guard inputFile.length > 0 else {
            throw BaseError(description: "Audio file is empty")
        }

        let inputFormat = inputFile.processingFormat
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)

        guard let outputFormat = outputFormat else {
            throw BaseError(description: "Unable to create output format")
        }

        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw BaseError(description: "Unable to create converter")
        }

        let outputFrameCapacity = AVAudioFrameCount(Double(inputFile.length) * outputFormat.sampleRate / inputFormat.sampleRate)
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity) else {
            throw BaseError(description: "Unable to create output buffer")
        }

        let inputFrameCapacity = AVAudioFrameCount(inputFile.length)
        guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: inputFrameCapacity) else {
            throw BaseError(description: "Unable to create input buffer")
        }
        try inputFile.read(into: inputBuffer)

        return try convertBufferToPCMArray(converter, targetBuffer: outputBuffer, sourceBuffer: inputBuffer)
    }

}

// MARK: - Private methods

private extension DefaultAudioConverter {

    func convertBufferToPCMArray(
        _ converter: AVAudioConverter,
        targetBuffer: AVAudioPCMBuffer,
        sourceBuffer: AVAudioPCMBuffer
    ) throws -> [Float] {
        // Convert the audio
        var error: NSError?
        let status = converter.convert(to: targetBuffer, error: &error) { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return sourceBuffer
        }

        if status != .endOfStream && error != nil {
            throw error!
        }

        // Extract the float PCM data from the output buffer
        guard let channelData = targetBuffer.floatChannelData?[0] else {
            throw BaseError(description: "No channel data")
        }

        let frameLength = Int(targetBuffer.frameLength)
        let pcmArray = Array(UnsafeBufferPointer(start: channelData, count: frameLength))

        return pcmArray
    }

}
