//
//  ModuleL10n.swift
//  LocalizationKit
//

import Foundation
import SwiftUI

/// Localized string lookup for an SPM module or app target bundle.
public struct ModuleL10n {
    private let lookup: LocalizationLookup

    public init(
        bundle: Bundle,
        configuration: AppLocalizationConfiguration,
        table: String? = nil,
        defaults: UserDefaults = .standard
    ) {
        lookup = LocalizationLookup(
            bundle: bundle,
            defaultsKey: configuration.defaultsKey,
            configuration: configuration.menu,
            defaults: defaults,
            table: table
        )
    }

    public init(
        bundle: Bundle,
        languageManager: LanguageManager,
        table: String? = nil
    ) {
        lookup = LocalizationLookup(
            bundle: bundle,
            languageManager: languageManager,
            table: table
        )
    }

    /// Bundle for the current language preference (`ko.lproj` / `en.lproj`).
    public var bundle: Bundle { lookup.resolvedBundle }

    public func tr(
        _ key: String.LocalizationValue,
        locale: Locale? = nil
    ) -> String {
        lookup.tr(key, locale: locale)
    }

    public func tr(
        _ key: String,
        locale: Locale? = nil
    ) -> String {
        lookup.tr(key, locale: locale)
    }

    public func trSync(_ key: String.LocalizationValue) -> String {
        lookup.trSync(key)
    }

    public func trSync(_ key: String) -> String {
        lookup.trSync(key)
    }

    public func format(
        _ key: String.LocalizationValue,
        _ arguments: CVarArg...,
        locale: Locale? = nil
    ) -> String {
        lookup.format(key, arguments, locale: locale)
    }

    public func format(
        _ key: String,
        _ arguments: CVarArg...,
        locale: Locale? = nil
    ) -> String {
        lookup.format(key, arguments, locale: locale)
    }
}

/// Static string API for modules that adopt `LocalizedModule`.
///
/// ```swift
/// private enum MyCoreLocalization: LocalizedModule { ... }
/// public typealias L10n = L10nNamespace<MyCoreLocalization>
/// ```
public enum L10nNamespace<Module: LocalizedModule> {
    private static var l10n: ModuleL10n { Module.l10n }

    public static var bundle: Bundle { l10n.bundle }

    public static func tr(
        _ key: String.LocalizationValue,
        locale: Locale? = nil
    ) -> String {
        l10n.tr(key, locale: locale)
    }

    public static func tr(
        _ key: String,
        locale: Locale? = nil
    ) -> String {
        l10n.tr(key, locale: locale)
    }

    public static func trSync(_ key: String.LocalizationValue) -> String {
        l10n.trSync(key)
    }

    public static func trSync(_ key: String) -> String {
        l10n.trSync(key)
    }

    public static func format(
        _ key: String.LocalizationValue,
        _ arguments: CVarArg...,
        locale: Locale? = nil
    ) -> String {
        l10n.format(key, arguments, locale: locale)
    }

    public static func format(
        _ key: String,
        _ arguments: CVarArg...,
        locale: Locale? = nil
    ) -> String {
        l10n.format(key, arguments, locale: locale)
    }
}
