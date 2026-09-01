//
//  AppLocalizationConfiguration.swift
//  LocalizationKit
//

import Foundation

/// Per-app language registration: `UserDefaults` key and menu whitelist.
///
/// Create one instance per app (or per independent language domain) and pass it to
/// `LanguageManager`, `ModuleL10n`, and SwiftUI helpers instead of repeating
/// `defaultsKey` + `LanguageMenuConfiguration` at every call site.
public struct AppLocalizationConfiguration: Sendable {
    public let defaultsKey: String
    public let menu: LanguageMenuConfiguration

    public init(
        defaultsKey: String,
        menu: LanguageMenuConfiguration
    ) {
        self.defaultsKey = defaultsKey
        self.menu = menu
    }

    /// Reads the stored preference without creating a `LanguageManager`.
    public func loadPreference(
        defaults: UserDefaults = .standard
    ) -> LanguagePreference {
        LanguageManager.loadPreference(
            defaultsKey: defaultsKey,
            configuration: menu,
            defaults: defaults
        )
    }

    /// Resolves the effective UI language for the stored preference.
    public func resolvedLanguage(
        defaults: UserDefaults = .standard
    ) -> AppLanguage {
        AppLanguage.resolve(
            preference: loadPreference(defaults: defaults),
            configuration: menu
        )
    }

    /// Creates a `LanguageManager` bound to this registration.
    @MainActor
    public func makeLanguageManager(
        defaults: UserDefaults = .standard
    ) -> LanguageManager {
        LanguageManager(
            defaultsKey: defaultsKey,
            configuration: menu,
            defaults: defaults
        )
    }

    /// Returns a cached `LanguageManager` for this `defaultsKey` (main-actor only).
    @MainActor
    public func languageManager(
        defaults: UserDefaults = .standard
    ) -> LanguageManager {
        LanguageManagerCache.shared.manager(
            for: self,
            defaults: defaults
        )
    }

    /// Creates a lookup helper for strings in the given bundle.
    public func makeModuleL10n(
        bundle: Bundle,
        table: String? = nil,
        defaults: UserDefaults = .standard
    ) -> ModuleL10n {
        ModuleL10n(
            bundle: bundle,
            configuration: self,
            table: table,
            defaults: defaults
        )
    }

    /// Creates a lookup helper that follows a live `LanguageManager`.
    public func makeModuleL10n(
        bundle: Bundle,
        languageManager: LanguageManager,
        table: String? = nil
    ) -> ModuleL10n {
        ModuleL10n(
            bundle: bundle,
            languageManager: languageManager,
            table: table
        )
    }
}

@MainActor
private final class LanguageManagerCache {
    static let shared = LanguageManagerCache()

    private var managers: [String: LanguageManager] = [:]

    func manager(
        for configuration: AppLocalizationConfiguration,
        defaults: UserDefaults
    ) -> LanguageManager {
        if let existing = managers[configuration.defaultsKey] {
            return existing
        }
        let manager = configuration.makeLanguageManager(defaults: defaults)
        managers[configuration.defaultsKey] = manager
        return manager
    }
}
