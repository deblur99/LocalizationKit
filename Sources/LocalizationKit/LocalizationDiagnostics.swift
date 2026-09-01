//
//  LocalizationDiagnostics.swift
//  LocalizationKit
//

import Foundation
import os

/// DEBUG-only diagnostics for invalid locale / language preference input.
enum LocalizationDiagnostics {
    private static let logger = Logger(
        subsystem: "com.deblur.LocalizationKit",
        category: "Language"
    )

    static func logInvalidStorageValue(
        _ raw: String,
        defaultsKey: String,
        suggestions: [AppLanguage]
    ) {
        #if DEBUG
        if suggestions.isEmpty {
            logger.warning(
                "Unknown language preference '\(raw, privacy: .public)' for key '\(defaultsKey, privacy: .public)'. Falling back to system."
            )
        } else {
            let hint = formatSuggestionList(suggestions)
            logger.warning(
                "Unknown language preference '\(raw, privacy: .public)' for key '\(defaultsKey, privacy: .public)'. Did you mean \(hint, privacy: .public)? Falling back to system."
            )
        }
        #endif
    }

    static func logExplicitLanguageNotInWhitelist(
        _ language: AppLanguage,
        configuration: LanguageMenuConfiguration
    ) {
        #if DEBUG
        let suggestions = AppLanguage.suggestions(
            for: language.rawValue,
            in: configuration.menuWhitelist
        )
        if suggestions.isEmpty {
            logger.warning(
                "Language '\(language.rawValue, privacy: .public)' is not in this app's whitelist. Falling back to \(configuration.fallbackLanguage.rawValue, privacy: .public)."
            )
        } else {
            let hint = formatSuggestionList(suggestions)
            logger.warning(
                "Language '\(language.rawValue, privacy: .public)' is not in this app's whitelist. Did you mean \(hint, privacy: .public)? Falling back to \(configuration.fallbackLanguage.rawValue, privacy: .public)."
            )
        }
        #endif
    }

    static func logUnrecognizedSystemLanguage(
        _ identifier: String,
        configuration: LanguageMenuConfiguration
    ) {
        #if DEBUG
        let suggestions = AppLanguage.suggestions(
            for: identifier,
            in: configuration.menuWhitelist
        )
        if suggestions.isEmpty {
            logger.debug(
                "System language '\(identifier, privacy: .public)' is not in the catalog. Skipping."
            )
        } else {
            let hint = formatSuggestionList(suggestions)
            logger.debug(
                "System language '\(identifier, privacy: .public)' did not match the catalog. Did you mean \(hint, privacy: .public)?"
            )
        }
        #endif
    }

    static func logSystemLanguageNotInWhitelist(
        _ identifier: String,
        matched: AppLanguage,
        configuration: LanguageMenuConfiguration
    ) {
        #if DEBUG
        let suggestions = AppLanguage.suggestions(
            for: matched.rawValue,
            in: configuration.menuWhitelist
        )
        if suggestions.isEmpty {
            logger.debug(
                "System language '\(identifier, privacy: .public)' maps to '\(matched.rawValue, privacy: .public)', which is not in this app's whitelist. Falling back."
            )
        } else {
            let hint = formatSuggestionList(suggestions)
            logger.debug(
                "System language '\(identifier, privacy: .public)' maps to '\(matched.rawValue, privacy: .public)', which is not whitelisted. Did you mean \(hint, privacy: .public)?"
            )
        }
        #endif
    }

    private static func formatSuggestionList(_ suggestions: [AppLanguage]) -> String {
        suggestions
            .map { "\($0.rawValue) (\($0.displayName))" }
            .joined(separator: ", ")
    }
}
