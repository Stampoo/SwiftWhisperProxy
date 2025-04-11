//
//  AudioConverterTests.swift
//  SwiftWhisperProxy
//
//  Created by Ilia Knyazkov on 10.04.2025.
//


import Foundation
import AVFoundation
import Testing
@testable import SwiftWhisperProxy

@Suite
struct AudioConverterTests {

    @Test
    func testConvertValid44kHzStereoTo16kHzMono() throws {
        let audiofilePath = UtilsForTests.audioFile
        let converter: AudioConverter = DefaultAudioConverter()
        let result = try converter.convertWavFileTo16kHzPCMArray(from: audiofilePath)

        let inputFile = try AVAudioFile(forReading: audiofilePath)
        let inputSampleRate = inputFile.processingFormat.sampleRate
        let inputFrames = Double(inputFile.length)
        let duration = inputFrames / inputSampleRate
        let expectedFrames = Int(duration * 16000)

        #expect(result.count == expectedFrames)
    }

    @Test
    func testConvertValid44kHzStereoDataTo16kHzMono() async throws {
        let audiofilePath = UtilsForTests.audioFile
        let url = URL(string: "https://www.google.com")

        #expect(url != nil)

        var request = URLRequest(url: url!)
        request.httpBody = try Data(contentsOf: audiofilePath)

        #expect(request.httpBody != nil)

        let converter: AudioConverter = DefaultAudioConverter()
        let result = try await converter.convertBufferTo16kHzPCMArray(from: request.httpBody!)

        let inputFile = try AVAudioFile(forReading: audiofilePath)
        let inputSampleRate = inputFile.processingFormat.sampleRate
        let inputFrames = Double(inputFile.length)
        let duration = inputFrames / inputSampleRate
        let expectedFrames = Int(duration * 16000)

        #expect(result.count == expectedFrames)
    }

}
