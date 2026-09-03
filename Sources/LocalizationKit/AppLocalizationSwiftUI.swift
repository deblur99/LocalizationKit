//
//  AppLocalizationSwiftUI.swift
//  LocalizationKit
//

import SwiftUI

extension LanguageManager {
    public convenience init(
        configuration: AppLocalizationConfiguration,
        defaults: UserDefaults = .standard
    ) {
        self.init(
            defaultsKey: configuration.defaultsKey,
            configuration: configuration.menu,
            defaults: defaults
        )
    }
}

extension View {
    @MainActor
    public func appLanguageEnvironment(
        _ configuration: AppLocalizationConfiguration
    ) -> some View {
        appLanguageEnvironment(configuration.languageManager())
    }

    @MainActor
    public func appLanguageEnvironment<M: LocalizedModule>(
        _ module: M.Type
    ) -> some View {
        appLanguageEnvironment(M.localization)
    }
}

extension LanguageMenuButton {
    @MainActor
    public init(
        configuration: AppLocalizationConfiguration,
        style: LanguageMenuButtonStyle = .toolbarIcon
    ) {
        self.init(
            languageManager: configuration.languageManager(),
            style: style
        )
    }

    @MainActor
    public init<M: LocalizedModule>(
        module: M.Type,
        style: LanguageMenuButtonStyle = .toolbarIcon
    ) {
        self.init(languageManager: M.languageManager, style: style)
    }
}

extension Text {
    public init(l10n key: LocalizedStringKey, module: ModuleL10n) {
        self.init(key, bundle: module.bundle)
    }

    public init<M: LocalizedModule>(l10n key: LocalizedStringKey, module: M.Type) {
        self.init(l10n: key, module: M.l10n)
    }
}

extension String {
    public func localized(using module: ModuleL10n) -> String {
        module.trSync(self)
    }

    public func localized<M: LocalizedModule>(using module: M.Type) -> String {
        module.l10n.trSync(self)
    }
}

extension LocalizationLookup {
    public static func module(
        bundle: Bundle,
        configuration: AppLocalizationConfiguration,
        table: String? = nil,
        defaults: UserDefaults = .standard
    ) -> LocalizationLookup {
        LocalizationLookup(
            bundle: bundle,
            defaultsKey: configuration.defaultsKey,
            configuration: configuration.menu,
            defaults: defaults,
            table: table
        )
    }
}
