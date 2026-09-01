//
//  LanguageMenuButton.swift
//  LocalizationKit
//

import SwiftUI

/// Globe menu: use system language, then whitelisted supported languages.
public struct LanguageMenuButton: View {
    @ObservedObject private var languageManager: LanguageManager

    public init(languageManager: LanguageManager) {
        self.languageManager = languageManager
    }

    public var body: some View {
        let ui = LocalizationLookup.kitUI(languageManager: languageManager)

        Menu {
            Button {
                languageManager.select(.system)
            } label: {
                menuLabel(
                    title: ui.trSync("Use System Language"),
                    selected: languageManager.preference == .system
                )
            }

            Divider()

            ForEach(languageManager.menuLanguages, id: \.rawValue) { language in
                Button {
                    languageManager.select(language: language)
                } label: {
                    menuLabel(
                        title: language.displayName,
                        selected: languageManager.preference == .explicit(language)
                    )
                }
            }
        } label: {
            Image(systemName: "globe")
        }
        .help(Text("Change language", bundle: ui.resolvedBundle))
        .accessibilityLabel(Text("Language", bundle: ui.resolvedBundle))
        .accessibilityHint(
            Text(
                "Choose the system language or a specific language for the app interface.",
                bundle: ui.resolvedBundle
            )
        )
        .accessibilityValue(Text(accessibilityValue(ui: ui)))
    }

    private func accessibilityValue(ui: LocalizationLookup) -> String {
        if languageManager.preference == .system {
            return ui.format(
                "System (%@)",
                languageManager.resolvedLanguage.displayName
            )
        }
        return languageManager.resolvedLanguage.displayName
    }

    @ViewBuilder
    private func menuLabel(title: String, selected: Bool) -> some View {
        if selected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
}
