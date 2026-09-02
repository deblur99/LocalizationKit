//
//  LocalizationLookup.swift
//  LocalizationKit
//

import Foundation
import SwiftUI

/// Loads the matching `*.lproj` bundle explicitly for in-app language overrides.
///
/// Passing `locale:` to `String(localized:bundle:locale:)` on an SPM `Bundle.module`
/// does not reliably select translations when the in-app language differs from the
/// system language.
public struct LocalizationLookup {
    private let bundle: Bundle
    private let defaultsKey: String
    private let configuration: LanguageMenuConfiguration
    private let defaults: UserDefaults
    private let table: String?

    public init(
        bundle: Bundle,
        defaultsKey: String,
        configuration: LanguageMenuConfiguration,
        defaults: UserDefaults = .standard,
        table: String? = nil
    ) {
        self.bundle = bundle
        self.defaultsKey = defaultsKey
        self.configuration = configuration
        self.defaults = defaults
        self.table = table
    }

    public init(
        bundle: Bundle,
        languageManager: LanguageManager,
        table: String? = nil
    ) {
        self.init(
            bundle: bundle,
            defaultsKey: languageManager.defaultsKey,
            configuration: languageManager.configuration,
            defaults: languageManager.defaults,
            table: table
        )
    }

    /// Bundle for the current resolved language (`ko.lproj` / `en.lproj`).
    public var resolvedBundle: Bundle {
        localizationBundle(for: resolvedLanguage())
    }

    public func tr(
        _ key: String.LocalizationValue,
        locale: Locale? = nil
    ) -> String {
        String(
            localized: key,
            table: table,
            bundle: localizationBundle(for: language(for: locale))
        )
    }

    public func tr(
        _ key: String,
        locale: Locale? = nil
    ) -> String {
        localizationBundle(for: language(for: locale))
            .localizedString(forKey: key, value: nil, table: table)
    }

    public func trSync(_ key: String.LocalizationValue) -> String {
        tr(key)
    }

    public func trSync(_ key: String) -> String {
        tr(key)
    }

    public func format(
        _ key: String.LocalizationValue,
        _ arguments: [CVarArg],
        locale: Locale? = nil
    ) -> String {
        let language = language(for: locale)
        let template = String(
            localized: key,
            table: table,
            bundle: localizationBundle(for: language)
        )
        return String(format: template, locale: language.locale, arguments: arguments)
    }

    public func format(
        _ key: String,
        _ arguments: [CVarArg],
        locale: Locale? = nil
    ) -> String {
        let language = language(for: locale)
        let template = tr(key, locale: language.locale)
        return String(format: template, locale: language.locale, arguments: arguments)
    }

    public func format(
        _ key: String.LocalizationValue,
        _ arguments: CVarArg...,
        locale: Locale? = nil
    ) -> String {
        format(key, Array(arguments), locale: locale)
    }

    public func format(
        _ key: String,
        _ arguments: CVarArg...,
        locale: Locale? = nil
    ) -> String {
        format(key, Array(arguments), locale: locale)
    }

    private func resolvedLanguage() -> AppLanguage {
        let preference = LanguageManager.loadPreference(
            defaultsKey: defaultsKey,
            configuration: configuration,
            defaults: defaults
        )
        return AppLanguage.resolve(
            preference: preference,
            configuration: configuration
        )
    }

    private func language(for locale: Locale?) -> AppLanguage {
        guard let locale else {
            return resolvedLanguage()
        }
        return AppLanguage.matching(languageIdentifier: locale.identifier)
            ?? configuration.fallbackLanguage
    }

    private func localizationBundle(for language: AppLanguage) -> Bundle {
        if let localized = localizedBundle(forLprojResourceName: language.rawValue) {
            return localized
        }

        let fallback = configuration.fallbackLanguage
        if fallback != language,
           let localized = localizedBundle(forLprojResourceName: fallback.rawValue) {
            return localized
        }

        return bundle
    }

    /// Resolves an `*.lproj` bundle, tolerating SPM resource bundles that lowercase locale folder names.
    ///
    /// 1. `rawValue` via `path(forResource:ofType:)`
    /// 2. lowercased `rawValue` via `path(forResource:ofType:)`
    /// 3. lowercased `rawValue` + `.lproj` as a direct subdirectory under the bundle
    private func localizedBundle(forLprojResourceName rawValue: String) -> Bundle? {
        Self.localizedBundle(in: bundle, forLprojResourceName: rawValue)
    }

    static func localizedBundle(in bundle: Bundle, forLprojResourceName rawValue: String) -> Bundle? {
        let lowercased = rawValue.lowercased()

        if let path = bundle.path(forResource: rawValue, ofType: "lproj"),
           let localized = Bundle(path: path) {
            return localized
        }

        if lowercased != rawValue,
           let path = bundle.path(forResource: lowercased, ofType: "lproj"),
           let localized = Bundle(path: path) {
            return localized
        }

        if let path = directLprojDirectoryPath(named: "\(lowercased).lproj", in: bundle),
           let localized = Bundle(path: path) {
            return localized
        }

        return nil
    }

    private static func directLprojDirectoryPath(named directoryName: String, in bundle: Bundle) -> String? {
        let searchRoots = [bundle.resourcePath, bundle.bundlePath]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        for root in searchRoots {
            let path = (root as NSString).appendingPathComponent(directoryName)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
               isDirectory.boolValue {
                return path
            }
        }

        return nil
    }

    private func directLprojDirectoryPath(named directoryName: String) -> String? {
        Self.directLprojDirectoryPath(named: directoryName, in: bundle)
    }
}

extension LocalizationLookup {
    /// Lookup for LocalizationKit UI strings (`LocalizationUI` table).
    public static func kitUI(languageManager: LanguageManager) -> LocalizationLookup {
        LocalizationLookup(
            bundle: .module,
            defaultsKey: languageManager.defaultsKey,
            configuration: languageManager.configuration,
            defaults: languageManager.defaults,
            table: "LocalizationUI"
        )
    }
}
