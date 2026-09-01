//
//  AppLanguage.swift
//  LocalizationKit
//

import Foundation

/// Supported UI languages. `rawValue` matches the `*.lproj` folder name in product bundles.
public enum AppLanguage: String, CaseIterable, Sendable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case hindi = "hi"
    case spanish = "es"
    case french = "fr"
    case arabic = "ar"
    case bengali = "bn"
    case portugueseBrazil = "pt-BR"
    case portuguesePortugal = "pt-PT"
    case russian = "ru"
    case urdu = "ur"
    case indonesian = "id"
    case german = "de"
    case japanese = "ja"
    case swahili = "sw"
    case marathi = "mr"
    case telugu = "te"
    case turkish = "tr"
    case tamil = "ta"
    case vietnamese = "vi"
    case korean = "ko"
    case italian = "it"
    case thai = "th"
    case gujarati = "gu"
    case polish = "pl"
    case ukrainian = "uk"
    case malay = "ms"
    case persian = "fa"
    case romanian = "ro"
    case dutch = "nl"
    case greek = "el"
    case czech = "cs"
    case swedish = "sv"
    case hungarian = "hu"
    case hebrew = "he"
    case danish = "da"
    case finnish = "fi"
    case norwegian = "nb"
    case slovak = "sk"
    case croatian = "hr"
    case catalan = "ca"
    case chineseTraditional = "zh-Hant"
    case filipino = "fil"

    /// Approximate speaker-rank order (Ethnologue / CLDR inspired).
    public static let catalogBySpeakerRank: [AppLanguage] = [
        .english,
        .chineseSimplified,
        .hindi,
        .spanish,
        .french,
        .arabic,
        .bengali,
        .portugueseBrazil,
        .portuguesePortugal,
        .russian,
        .urdu,
        .indonesian,
        .german,
        .japanese,
        .swahili,
        .marathi,
        .telugu,
        .turkish,
        .tamil,
        .vietnamese,
        .korean,
        .italian,
        .thai,
        .gujarati,
        .polish,
        .ukrainian,
        .malay,
        .persian,
        .romanian,
        .dutch,
        .greek,
        .czech,
        .swedish,
        .hungarian,
        .hebrew,
        .danish,
        .finnish,
        .norwegian,
        .slovak,
        .croatian,
        .catalan,
        .chineseTraditional,
        .filipino,
    ]

    public var locale: Locale { Locale(identifier: rawValue) }

    /// Native endonym for the language picker.
    public var displayName: String {
        switch self {
        case .english: "English"
        case .chineseSimplified: "简体中文"
        case .hindi: "हिन्दी"
        case .spanish: "Español"
        case .french: "Français"
        case .arabic: "العربية"
        case .bengali: "বাংলা"
        case .portugueseBrazil: "Português (Brasil)"
        case .portuguesePortugal: "Português (Portugal)"
        case .russian: "Русский"
        case .urdu: "اردو"
        case .indonesian: "Bahasa Indonesia"
        case .german: "Deutsch"
        case .japanese: "日本語"
        case .swahili: "Kiswahili"
        case .marathi: "मराठी"
        case .telugu: "తెలుగు"
        case .turkish: "Türkçe"
        case .tamil: "தமிழ்"
        case .vietnamese: "Tiếng Việt"
        case .korean: "한국어"
        case .italian: "Italiano"
        case .thai: "ไทย"
        case .gujarati: "ગુજરાતી"
        case .polish: "Polski"
        case .ukrainian: "Українська"
        case .malay: "Bahasa Melayu"
        case .persian: "فارسی"
        case .romanian: "Română"
        case .dutch: "Nederlands"
        case .greek: "Ελληνικά"
        case .czech: "Čeština"
        case .swedish: "Svenska"
        case .hungarian: "Magyar"
        case .hebrew: "עברית"
        case .danish: "Dansk"
        case .finnish: "Suomi"
        case .norwegian: "Norsk"
        case .slovak: "Slovenčina"
        case .croatian: "Hrvatski"
        case .catalan: "Català"
        case .chineseTraditional: "繁體中文"
        case .filipino: "Filipino"
        }
    }

    /// Maps a BCP-47 / Apple language identifier onto a supported app language.
    public static func matching(languageIdentifier: String) -> AppLanguage? {
        let id = languageIdentifier.replacingOccurrences(of: "_", with: "-")
        let lower = id.lowercased()

        if lower.hasPrefix("zh-hant")
            || lower.hasPrefix("zh-tw")
            || lower.hasPrefix("zh-hk")
            || lower.hasPrefix("zh-mo") {
            return .chineseTraditional
        }
        if lower.hasPrefix("zh-hans")
            || lower.hasPrefix("zh-cn")
            || lower.hasPrefix("zh-sg") {
            return .chineseSimplified
        }
        if lower.hasPrefix("zh") {
            return .chineseSimplified
        }

        if lower.hasPrefix("pt-br") { return .portugueseBrazil }
        if lower.hasPrefix("pt-pt") { return .portuguesePortugal }
        if lower == "pt" || lower.hasPrefix("pt-") { return .portugueseBrazil }
        if lower.hasPrefix("fil") || lower.hasPrefix("tl") { return .filipino }
        if lower.hasPrefix("nb") || lower.hasPrefix("nn") || lower.hasPrefix("no") { return .norwegian }

        let prefixMap: [(String, AppLanguage)] = [
            ("en", .english),
            ("hi", .hindi),
            ("es", .spanish),
            ("fr", .french),
            ("ar", .arabic),
            ("bn", .bengali),
            ("ru", .russian),
            ("ur", .urdu),
            ("id", .indonesian),
            ("de", .german),
            ("ja", .japanese),
            ("sw", .swahili),
            ("mr", .marathi),
            ("te", .telugu),
            ("tr", .turkish),
            ("ta", .tamil),
            ("vi", .vietnamese),
            ("ko", .korean),
            ("it", .italian),
            ("th", .thai),
            ("gu", .gujarati),
            ("pl", .polish),
            ("uk", .ukrainian),
            ("ms", .malay),
            ("fa", .persian),
            ("ro", .romanian),
            ("nl", .dutch),
            ("el", .greek),
            ("cs", .czech),
            ("sv", .swedish),
            ("hu", .hungarian),
            ("he", .hebrew),
            ("da", .danish),
            ("fi", .finnish),
            ("sk", .slovak),
            ("hr", .croatian),
            ("ca", .catalan),
        ]

        for (prefix, language) in prefixMap where lower.hasPrefix(prefix) {
            return language
        }

        return nil
    }

    /// System policy: first preferred language in the whitelist, otherwise fallback.
    public static func fromSystem(configuration: LanguageMenuConfiguration) -> AppLanguage {
        for preferred in Locale.preferredLanguages {
            if let match = matching(languageIdentifier: preferred) {
                if configuration.menuWhitelist.contains(match) {
                    return match
                }
                LocalizationDiagnostics.logSystemLanguageNotInWhitelist(
                    preferred,
                    matched: match,
                    configuration: configuration
                )
            } else {
                LocalizationDiagnostics.logUnrecognizedSystemLanguage(
                    preferred,
                    configuration: configuration
                )
            }
        }
        return configuration.fallbackLanguage
    }

    public static func resolve(
        preference: LanguagePreference,
        configuration: LanguageMenuConfiguration
    ) -> AppLanguage {
        switch preference {
        case .system:
            return fromSystem(configuration: configuration)
        case .explicit(let language):
            if configuration.menuWhitelist.contains(language) {
                return language
            }
            LocalizationDiagnostics.logExplicitLanguageNotInWhitelist(
                language,
                configuration: configuration
            )
            return configuration.fallbackLanguage
        }
    }
}
