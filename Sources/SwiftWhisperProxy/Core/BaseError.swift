//
//  BaseError.swift
//  SwiftWhisperProxy
//
//  Created by Илья Князьков on 09.04.2025.
//

import Foundation

public struct BaseError {

    // MARK: - Private properties

    private let description: String

    // MARK: - Initialziation

    public init(description: String) {
        self.description = description
    }

}

// MARK: - LocalizedError

extension BaseError: LocalizedError {

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        description
    }

    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        description
    }

}
