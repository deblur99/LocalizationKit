//
//  LocalizationKitTests.swift
//  LocalizationKitTests
//

import Foundation
import Testing
@testable import LocalizationKit

@Suite("LocalizationKitTests", .serialized)
struct LocalizationKitTests {
    private let bslMenu = LanguageMenuConfiguration(menuWhitelist: [
        .korean,
        .english,
        .japanese,
        .chineseSimplified,
        .chineseTraditional,
        .german,
        .french,
        .spanish,
    ])

    @Test func languagePreferenceMigratesLegacyStorageValues() {
        #expect(LanguagePreference(storageValue: "korean") == .explicit(.korean))
        #expect(LanguagePreference(storageValue: "english") == .explicit(.english))
        #expect(LanguagePreference(storageValue: "ko") == .explicit(.korean))
        #expect(LanguagePreference(storageValue: "system") == .system)
    }

    @Test func languagePreferenceRoundTripsStorageValue() {
        #expect(LanguagePreference.system.storageValue == "system")
        #expect(LanguagePreference.explicit(.japanese).storageValue == "ja")
    }

    @Test func matchingCoversExpansionSet() {
        #expect(AppLanguage.matching(languageIdentifier: "ja-JP") == .japanese)
        #expect(AppLanguage.matching(languageIdentifier: "zh-Hans-CN") == .chineseSimplified)
        #expect(AppLanguage.matching(languageIdentifier: "zh-Hant-TW") == .chineseTraditional)
        #expect(AppLanguage.matching(languageIdentifier: "de-DE") == .german)
        #expect(AppLanguage.matching(languageIdentifier: "hi-IN") == .hindi)
        #expect(AppLanguage.matching(languageIdentifier: "pt-BR") == .portugueseBrazil)
        #expect(AppLanguage.matching(languageIdentifier: "pt-PT") == .portuguesePortugal)
        #expect(AppLanguage.matching(languageIdentifier: "pt") == .portugueseBrazil)
        #expect(AppLanguage.matching(languageIdentifier: "fil-PH") == .filipino)
        #expect(AppLanguage.catalogBySpeakerRank.count == 43)
    }

    @Test func resolveUsesWhitelistForExplicitPreference() {
        let resolved = AppLanguage.resolve(
            preference: .explicit(.hindi),
            configuration: bslMenu
        )
        #expect(resolved == .english)
    }

    @Test func resolveUsesWhitelistForSystemPreference() {
        let resolved = AppLanguage.resolve(
            preference: .explicit(.korean),
            configuration: bslMenu
        )
        #expect(resolved == .korean)
    }

    @Test func menuWhitelistPreservesBSLCount() {
        #expect(bslMenu.menuWhitelist.count == 8)
    }

    @Test func everyCatalogLanguageHasLocalizationUIStrings() {
        for language in AppLanguage.allCases {
            let localizedBundle = LocalizationLookup.localizedBundle(
                in: .module,
                forLprojResourceName: language.rawValue
            )
            #expect(localizedBundle != nil, "Missing \(language.rawValue).lproj for \(language)")

            guard let localizedBundle else { continue }

            let lprojPath = localizedBundle.bundlePath
            let stringsPath = (lprojPath as NSString)
                .appendingPathComponent("LocalizationUI.strings")
            #expect(
                FileManager.default.fileExists(atPath: stringsPath),
                "Missing LocalizationUI.strings in \(language.rawValue).lproj"
            )

            let languageLabel = localizedBundle.localizedString(
                forKey: "Language",
                value: "__MISSING__",
                table: "LocalizationUI"
            )
            #expect(languageLabel != "__MISSING__")

            if language != .english {
                #expect(
                    languageLabel != "Language",
                    "Expected a non-English LocalizationUI string for \(language.rawValue)"
                )
            }
        }

        #expect(AppLanguage.allCases.count == 43)
    }

    @Test func suggestionsRanksTypoAndPrefixMatches() {
        let candidates = bslMenu.menuWhitelist

        #expect(AppLanguage.suggestions(for: "kro", in: candidates) == [.korean])
        #expect(AppLanguage.suggestions(for: "jap", in: candidates) == [.japanese])
        #expect(AppLanguage.suggestions(for: "en", in: candidates) == [.english])
        #expect(AppLanguage.suggestions(for: "zz", in: candidates).isEmpty)
    }

    @Test func loadPreferenceFallsBackForInvalidStorageValue() {
        let defaults = UserDefaults(suiteName: "LocalizationKitTests.invalidPreference")!
        defaults.removePersistentDomain(forName: "LocalizationKitTests.invalidPreference")
        defaults.set("kro", forKey: "test.language")

        let preference = LanguageManager.loadPreference(
            defaultsKey: "test.language",
            configuration: bslMenu,
            defaults: defaults
        )
        #expect(preference == .system)
    }

    @Test func appLocalizationConfigurationResolvesLanguage() {
        let defaults = UserDefaults(suiteName: "LocalizationKitTests.appConfig")!
        defaults.removePersistentDomain(forName: "LocalizationKitTests.appConfig")
        defaults.set(AppLanguage.korean.rawValue, forKey: "app.language")

        let configuration = AppLocalizationConfiguration(
            defaultsKey: "app.language",
            menu: bslMenu
        )

        #expect(configuration.loadPreference(defaults: defaults) == .explicit(.korean))
        #expect(configuration.resolvedLanguage(defaults: defaults) == .korean)
    }

    @Test func moduleL10nMatchesLookup() {
        let configuration = AppLocalizationConfiguration(
            defaultsKey: "test.moduleL10n",
            menu: bslMenu
        )
        let defaults = UserDefaults(suiteName: "LocalizationKitTests.moduleL10n")!
        defaults.removePersistentDomain(forName: "LocalizationKitTests.moduleL10n")
        defaults.set(AppLanguage.english.rawValue, forKey: "test.moduleL10n")

        let l10n = configuration.makeModuleL10n(
            bundle: .module,
            table: "LocalizationUI",
            defaults: defaults
        )
        #expect(l10n.trSync("Language") == "Language")
    }

    @Test @MainActor func localizedModuleProvidesSharedManager() {
        enum TestModule: LocalizedModule {
            static let localization = AppLocalizationConfiguration(
                defaultsKey: "test.localizedModule",
                menu: LanguageMenuConfiguration(menuWhitelist: [.english])
            )
            static let stringsBundle = Bundle.module
            static let stringsTable = "LocalizationUI"
        }

        let first = TestModule.languageManager
        let second = TestModule.languageManager
        #expect(first === second)
        #expect(TestModule.l10n.trSync("Language") == "Language")
    }

    @Test func l10nNamespaceForwardsToModuleL10n() {
        enum TestModule: LocalizedModule {
            static let localization = AppLocalizationConfiguration(
                defaultsKey: "test.l10nNamespace",
                menu: LanguageMenuConfiguration(menuWhitelist: [.english])
            )
            static let stringsBundle = Bundle.module
            static let stringsTable = "LocalizationUI"
        }

        typealias L10n = L10nNamespace<TestModule>
        #expect(L10n.trSync("Language") == "Language")
    }

    @Test @MainActor func kitUILookupResolvesEnglishStrings() {
        let defaults = UserDefaults(suiteName: "LocalizationKitTests.kitUI")!
        defaults.removePersistentDomain(forName: "LocalizationKitTests.kitUI")
        defaults.set(AppLanguage.english.rawValue, forKey: "test.language")

        let manager = LanguageManager(
            defaultsKey: "test.language",
            configuration: bslMenu,
            defaults: defaults
        )
        let ui = LocalizationLookup.kitUI(languageManager: manager)
        #expect(ui.trSync("Use System Language") == "Use System Language")
    }

    @Test func localizationLookupFallsBackToLowercasedLprojDirectory() throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("LocalizationKitTests.lowercaseLproj", isDirectory: true)
        try? FileManager.default.removeItem(at: tempRoot)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)

        let bundleRoot = tempRoot.appendingPathComponent("TestStrings.bundle", isDirectory: true)
        let lproj = bundleRoot.appendingPathComponent("zh-hans.lproj", isDirectory: true)
        try FileManager.default.createDirectory(at: lproj, withIntermediateDirectories: true)

        let strings = """
        "Settings" = "设置";
        """
        try strings.write(
            to: lproj.appendingPathComponent("Localizable.strings"),
            atomically: true,
            encoding: .utf8
        )

        let defaults = UserDefaults(suiteName: "LocalizationKitTests.lowercaseLproj")!
        defaults.removePersistentDomain(forName: "LocalizationKitTests.lowercaseLproj")
        defaults.set(AppLanguage.chineseSimplified.rawValue, forKey: "test.lowercaseLproj")

        let lookup = LocalizationLookup(
            bundle: Bundle(path: bundleRoot.path)!,
            defaultsKey: "test.lowercaseLproj",
            configuration: bslMenu,
            defaults: defaults
        )

        #expect(lookup.trSync("Settings") == "设置")

        try? FileManager.default.removeItem(at: tempRoot)
    }
}
