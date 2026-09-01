//
//  LanguageManager.swift
//  LocalizationKit
//

import Combine
import Foundation
import SwiftUI

/// Persists language preference and publishes the resolved locale for live UI refresh.
@MainActor
public final class LanguageManager: ObservableObject {
    public let defaultsKey: String
    public let configuration: LanguageMenuConfiguration

    public nonisolated let defaults: UserDefaults

    @Published public var preference: LanguagePreference {
        didSet {
            persist(preference)
            resolvedLanguage = AppLanguage.resolve(
                preference: preference,
                configuration: configuration
            )
        }
    }

    @Published public private(set) var resolvedLanguage: AppLanguage

    public var locale: Locale { resolvedLanguage.locale }

    /// Languages shown in the language picker for this app.
    public var menuLanguages: [AppLanguage] { configuration.menuWhitelist }

    public init(
        defaultsKey: String,
        configuration: LanguageMenuConfiguration,
        defaults: UserDefaults = .standard
    ) {
        self.defaultsKey = defaultsKey
        self.configuration = configuration
        self.defaults = defaults

        let loaded = LanguageManager.loadPreference(
            defaultsKey: defaultsKey,
            configuration: configuration,
            defaults: defaults
        )
        preference = loaded
        resolvedLanguage = AppLanguage.resolve(
            preference: loaded,
            configuration: configuration
        )
        persist(loaded)
    }

    public func select(_ preference: LanguagePreference) {
        self.preference = preference
    }

    public func select(language: AppLanguage) {
        guard configuration.menuWhitelist.contains(language) else { return }
        preference = .explicit(language)
    }

    private func persist(_ preference: LanguagePreference) {
        defaults.set(preference.storageValue, forKey: defaultsKey)
    }
}

extension LanguageManager {
    /// Nonisolated read for synchronous string lookup off the main actor.
    public nonisolated static func loadPreference(
        defaultsKey: String,
        configuration: LanguageMenuConfiguration? = nil,
        defaults: UserDefaults = .standard
    ) -> LanguagePreference {
        guard let raw = defaults.string(forKey: defaultsKey) else {
            return .system
        }

        if let value = LanguagePreference(storageValue: raw) {
            return value
        }

        let candidates = configuration?.menuWhitelist ?? AppLanguage.catalogBySpeakerRank
        LocalizationDiagnostics.logInvalidStorageValue(
            raw,
            defaultsKey: defaultsKey,
            suggestions: AppLanguage.suggestions(for: raw, in: candidates)
        )
        return .system
    }
}

/// Applies the resolved app locale and forces SwiftUI to rebuild when language changes.
@MainActor
public struct AppLanguageEnvironmentModifier: ViewModifier {
    @ObservedObject var languageManager: LanguageManager

    public init(languageManager: LanguageManager) {
        self.languageManager = languageManager
    }

    public func body(content: Content) -> some View {
        content
            .environmentObject(languageManager)
            .environment(\.locale, languageManager.locale)
            .id(languageManager.resolvedLanguage.rawValue)
    }
}

extension View {
    @MainActor
    public func appLanguageEnvironment(_ languageManager: LanguageManager) -> some View {
        modifier(AppLanguageEnvironmentModifier(languageManager: languageManager))
    }
}
