//
//  LanguagePreference.swift
//  LocalizationKit
//

import Foundation

/// Explicit UI language preference. `system` follows the app language policy.
public enum LanguagePreference: Equatable, Hashable, Sendable {
    case system
    case explicit(AppLanguage)
}

extension LanguagePreference {
    /// Value persisted in `UserDefaults`.
    public var storageValue: String {
        switch self {
        case .system:
            return "system"
        case .explicit(let language):
            return language.rawValue
        }
    }

    /// Reads a stored preference, including legacy `korean` / `english` keys.
    public init?(storageValue: String) {
        if storageValue == "system" {
            self = .system
            return
        }

        if let legacy = Self.legacyLanguage(from: storageValue) {
            self = .explicit(legacy)
            return
        }

        if let language = AppLanguage(rawValue: storageValue) {
            self = .explicit(language)
            return
        }

        return nil
    }

    private static func legacyLanguage(from storageValue: String) -> AppLanguage? {
        switch storageValue {
        case "korean": .korean
        case "english": .english
        case "japanese": .japanese
        case "chineseSimplified": .chineseSimplified
        case "chineseTraditional": .chineseTraditional
        case "german": .german
        case "french": .french
        case "spanish": .spanish
        default: nil
        }
    }
}
