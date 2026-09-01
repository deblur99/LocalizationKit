//
//  LanguageMenuConfiguration.swift
//  LocalizationKit
//

import Foundation

/// Per-app language menu whitelist and fallback policy.
public struct LanguageMenuConfiguration: Sendable {
    /// Languages shown in the picker, in display order.
    public let menuWhitelist: [AppLanguage]
    /// Used when system language is unsupported or an explicit choice is stale.
    public let fallbackLanguage: AppLanguage

    public init(
        menuWhitelist: [AppLanguage],
        fallbackLanguage: AppLanguage = .english
    ) {
        self.menuWhitelist = menuWhitelist
        self.fallbackLanguage = fallbackLanguage
    }
}
