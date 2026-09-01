//
//  AppLanguage+Suggestions.swift
//  LocalizationKit
//

import Foundation

extension AppLanguage {
    /// Suggests whitelisted languages similar to free-form user input.
    ///
    /// Ranking: exact → prefix → edit distance ≤ 2 (on codes ≥ 2 chars) → shared substring (≥ 3 chars).
    public static func suggestions(
        for input: String,
        in candidates: [AppLanguage],
        limit: Int = 3
    ) -> [AppLanguage] {
        let normalized = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !normalized.isEmpty, normalized != "system" else { return [] }

        var scored: [(language: AppLanguage, score: Int)] = []

        for language in candidates {
            let score = bestMatchScore(input: normalized, labels: matchLabels(for: language))
            if score > 0 {
                scored.append((language, score))
            }
        }

        var seen = Set<AppLanguage>()
        let maxScore = scored.map(\.score).max() ?? 0
        let minimumScore = max(60, maxScore - 5)

        return scored
            .filter { $0.score >= minimumScore }
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score > rhs.score }
                return lhs.language.rawValue < rhs.language.rawValue
            }
            .compactMap { entry in
                guard seen.insert(entry.language).inserted else { return nil }
                return entry.language
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func matchLabels(for language: AppLanguage) -> [String] {
        var labels = [language.rawValue]
        switch language {
        case .korean: labels.append("korean")
        case .english: labels.append("english")
        case .japanese: labels.append("japanese")
        case .chineseSimplified: labels.append(contentsOf: ["chinesesimplified", "zh-cn", "zh_cn"])
        case .chineseTraditional: labels.append(contentsOf: ["chinesetraditional", "zh-tw", "zh_tw"])
        case .german: labels.append("german")
        case .french: labels.append("french")
        case .spanish: labels.append("spanish")
        default: break
        }
        return labels.map { $0.lowercased() }
    }

    private static func bestMatchScore(input: String, labels: [String]) -> Int {
        labels.reduce(0) { best, label in
            max(best, matchScore(input: input, label: label))
        }
    }

    private static func matchScore(input: String, label: String) -> Int {
        if input == label { return 100 }
        if label.hasPrefix(input) || input.hasPrefix(label) { return 80 }

        if input.count >= 3, label.count >= 2 {
            let distance = levenshteinDistance(input, label)
            if distance <= 2 { return 70 - distance * 10 }
        }

        if input.count >= 3,
           label.count >= 3,
           (label.contains(input) || input.contains(label)) {
            return 50
        }

        if input.count == 1, label.hasPrefix(input) {
            return 40
        }

        return 0
    }

    private static func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let left = Array(lhs)
        let right = Array(rhs)
        if left.isEmpty { return right.count }
        if right.isEmpty { return left.count }

        var previous = Array(0 ... right.count)
        var current = Array(repeating: 0, count: right.count + 1)

        for i in 1 ... left.count {
            current[0] = i
            for j in 1 ... right.count {
                let cost = left[i - 1] == right[j - 1] ? 0 : 1
                current[j] = min(
                    current[j - 1] + 1,
                    previous[j] + 1,
                    previous[j - 1] + cost
                )
            }
            swap(&previous, &current)
        }

        return previous[right.count]
    }
}
