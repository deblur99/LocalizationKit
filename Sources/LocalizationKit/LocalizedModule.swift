//
//  LocalizedModule.swift
//  LocalizationKit
//

import Foundation

/// Adopt in an app or feature module to centralize localization registration.
///
/// ```swift
/// enum MyCoreLocalization: LocalizedModule {
///     static let localization = AppLocalizationConfiguration(
///         defaultsKey: "myapp.languagePreference",
///         menu: LanguageMenuConfiguration(menuWhitelist: [.english, .korean])
///     )
///     static let stringsBundle = Bundle.module
/// }
///
/// typealias L10n = L10nNamespace<MyCoreLocalization>
/// ```
public protocol LocalizedModule {
    /// Per-app language registration (`defaultsKey` + menu whitelist).
    static var localization: AppLocalizationConfiguration { get }
    /// Bundle that contains the module's `*.lproj` folders (usually `Bundle.module` in SPM).
    static var stringsBundle: Bundle { get }
    /// Strings table name, if not the default `Localizable`.
    static var stringsTable: String? { get }
}

extension LocalizedModule {
    public static var stringsTable: String? { nil }

    @MainActor
    public static var languageManager: LanguageManager {
        localization.languageManager()
    }

    public static var l10n: ModuleL10n {
        localization.makeModuleL10n(
            bundle: stringsBundle,
            table: stringsTable
        )
    }

    public static func resolvedLanguage(
        defaults: UserDefaults = .standard
    ) -> AppLanguage {
        localization.resolvedLanguage(defaults: defaults)
    }

    public static func loadPreference(
        defaults: UserDefaults = .standard
    ) -> LanguagePreference {
        localization.loadPreference(defaults: defaults)
    }
}
