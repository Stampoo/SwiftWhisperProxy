//
//  WhisperProxyTests.swift
//  SwiftWhisperProxy
//
//  Created by Claude on 04.04.2025.
//

import Foundation
import AVFoundation
import Testing
@testable import SwiftWhisperProxy

@Suite
struct WhisperProxyTests {

    @Test
    func testOnCorrectSpeechRecognition() async throws {
        let expectedText = "And so my fellow Americans ask not what your country can do for you, ask what you can do for your country."
        let model = UtilsForTests.model
        let audiofilePath = UtilsForTests.audioFile

        let whisperProxy: WhisperProxy = try NewWhisperProxy(model: model)
        let converter: AudioConverter = DefaultAudioConverter()

        for try await result in try whisperProxy.recognize(from: audiofilePath, converter: converter) {
            if result.isDone {
                #expect(try result.get().recognizedText == expectedText)
            } else {
                guard case .progressDidChanged(_) = result else {
                    Issue.record("Must be in progress")
                    return
                }
            }
        }
    }

    @Test
    func testOnCorrectSpeechRecognitionFromData() async throws {
        let expectedText = "And so my fellow Americans ask not what your country can do for you, ask what you can do for your country."
        let model = UtilsForTests.model
        let audiofilePath = UtilsForTests.audioFile
        let url = URL(string: "https://www.google.com")

        #expect(url != nil)

        var request = URLRequest(url: url!)
        request.httpBody = try Data(contentsOf: audiofilePath)

        #expect(request.httpBody != nil)

        let whisperProxy: WhisperProxy = try NewWhisperProxy(model: model)
        let converter: AudioConverter = DefaultAudioConverter()

        for try await result in try await whisperProxy.recognize(from: request.httpBody!, converter: converter) {
            if result.isDone {
                #expect(try result.get().recognizedText == expectedText)
            } else {
                guard case .progressDidChanged(_) = result else {
                    Issue.record("Must be in progress")
                    return
                }
            }
        }

    }

    @Test
    func testOnCorrectThrowingErrors() async throws {
        #expect(throws: Error.self) {
            let model = WhisperModel(path: URL(filePath: .init("")))
            let _ : WhisperProxy = try WhisperProxyImplementation(model: model)
        }

        await #expect(throws: Error.self) {
            let model = UtilsForTests.model
            let whisperProxy: WhisperProxy = try NewWhisperProxy(model: model)

            _ = try await whisperProxy.recognize(from: [])
        }

    }

    @Test
    func testOnCorrectSpeechRecognitionProgress() async throws { }

}
