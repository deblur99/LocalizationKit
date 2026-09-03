//
//  LanguageMenuButton.swift
//  LocalizationKit
//

import SwiftUI

/// Presentation style for ``LanguageMenuButton``.
public enum LanguageMenuButtonStyle: Sendable {
    /// Toolbar / navigation bar: globe icon only.
    case toolbarIcon
    /// Form / List row: current preference display name (platform `Menu` may add a chevron).
    case menuLabel
}

/// Language menu: use system language, then whitelisted supported languages.
///
/// On watchOS, SwiftUI `Menu` is unavailable, so this control uses a `Picker` instead.
public struct LanguageMenuButton: View {
    @ObservedObject private var languageManager: LanguageManager
    private let style: LanguageMenuButtonStyle

    public init(
        languageManager: LanguageManager,
        style: LanguageMenuButtonStyle = .toolbarIcon
    ) {
        self.languageManager = languageManager
        self.style = style
    }

    public var body: some View {
        let ui = LocalizationLookup.kitUI(languageManager: languageManager)

        #if os(watchOS)
        pickerControl(ui: ui)
        #else
        menuControl(ui: ui)
        #endif
    }

    #if os(watchOS)
    private var preferenceBinding: Binding<LanguagePreference> {
        Binding(
            get: { languageManager.preference },
            set: { languageManager.select($0) }
        )
    }

    @ViewBuilder
    private func pickerControl(ui: LocalizationLookup) -> some View {
        Picker(selection: preferenceBinding) {
            Text(ui.trSync("Use System Language"))
                .tag(LanguagePreference.system)

            ForEach(languageManager.menuLanguages, id: \.rawValue) { language in
                Text(language.displayName)
                    .tag(LanguagePreference.explicit(language))
            }
        } label: {
            buttonLabel(ui: ui)
        }
        .accessibilityLabel(Text("Language", bundle: ui.resolvedBundle))
        .accessibilityHint(
            Text(
                "Choose the system language or a specific language for the app interface.",
                bundle: ui.resolvedBundle
            )
        )
        .accessibilityValue(Text(accessibilityValue(ui: ui)))
    }
    #else
    @ViewBuilder
    private func menuControl(ui: LocalizationLookup) -> some View {
        Menu {
            Button {
                languageManager.select(.system)
            } label: {
                menuRowLabel(
                    title: ui.trSync("Use System Language"),
                    selected: languageManager.preference == .system
                )
            }

            Divider()

            ForEach(languageManager.menuLanguages, id: \.rawValue) { language in
                Button {
                    languageManager.select(language: language)
                } label: {
                    menuRowLabel(
                        title: language.displayName,
                        selected: languageManager.preference == .explicit(language)
                    )
                }
            }
        } label: {
            buttonLabel(ui: ui)
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
    #endif

    @ViewBuilder
    private func buttonLabel(ui: LocalizationLookup) -> some View {
        switch style {
        case .toolbarIcon:
            Image(systemName: "globe")
        case .menuLabel:
            Text(menuLabelTitle(ui: ui))
        }
    }

    /// Visible title for ``LanguageMenuButtonStyle/menuLabel``.
    private func menuLabelTitle(ui: LocalizationLookup) -> String {
        if languageManager.preference == .system {
            return ui.trSync("Use System Language")
        }
        return languageManager.resolvedLanguage.displayName
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

    #if !os(watchOS)
    @ViewBuilder
    private func menuRowLabel(title: String, selected: Bool) -> some View {
        if selected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
    #endif
}
