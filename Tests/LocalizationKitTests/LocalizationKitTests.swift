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
        #expect(AppLanguage.matching(languageIdentifier: "pt-BR") == .portuguese)
        #expect(AppLanguage.matching(languageIdentifier: "fil-PH") == .filipino)
        #expect(AppLanguage.catalogBySpeakerRank.count == 42)
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
            let lprojPath = Bundle.module.path(
                forResource: language.rawValue,
                ofType: "lproj"
            )
            #expect(lprojPath != nil, "Missing \(language.rawValue).lproj for \(language)")

            guard let lprojPath else { continue }

            let stringsPath = (lprojPath as NSString)
                .appendingPathComponent("LocalizationUI.strings")
            #expect(
                FileManager.default.fileExists(atPath: stringsPath),
                "Missing LocalizationUI.strings in \(language.rawValue).lproj"
            )

            guard let bundle = Bundle(path: lprojPath) else { continue }

            let languageLabel = bundle.localizedString(
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

        #expect(AppLanguage.allCases.count == 42)
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
}
