# LocalizationKit

Swift Package for in-app language switching on macOS and iOS. Provides a language catalog, preference persistence, explicit `*.lproj` bundle lookup, and a ready-made language menu UI.

## Requirements

- macOS 13+
- iOS 16+
- Swift 5.9+

## Installation

Add LocalizationKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/deblur99/LocalizationKit", from: "1.3.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "LocalizationKit", package: "LocalizationKit"),
        ]
    ),
]
```

Or add the package in Xcode: **File → Add Package Dependencies…** and enter the repository URL.

## Recommended adoption (minimal boilerplate)

Register your app once, then use `LocalizedModule` helpers instead of repeating `defaultsKey`, whitelist, and `LocalizationLookup` wiring.

### 1. Register the app

```swift
import LocalizationKit

enum MyCoreLocalization: LocalizedModule {
    static let localization = AppLocalizationConfiguration(
        defaultsKey: "myapp.languagePreference",
        menu: LanguageMenuConfiguration(
            menuWhitelist: [.korean, .english, .japanese],
            fallbackLanguage: .english
        )
    )
    static let stringsBundle = Bundle.module
}

public typealias L10n = L10nNamespace<MyCoreLocalization>
```

### 2. Shared manager and SwiftUI

```swift
@MainActor
let languageManager = MyCoreLocalization.languageManager

ContentView()
    .appLanguageEnvironment(MyCoreLocalization.self)

// Toolbar / navigation bar (default)
LanguageMenuButton(module: MyCoreLocalization.self)

// Form / List: show the current selection (e.g. "한국어")
LanguageMenuButton(module: MyCoreLocalization.self, style: .menuLabel)
```

### 3. Localized strings

```swift
let title = L10n.trSync("settings.title")
Text(l10n: "settings.title", module: MyCoreLocalization.self)
```

### 4. Business logic without a manager

```swift
let language = MyCoreLocalization.resolvedLanguage()
```

## Manual setup (lower-level API)

### 1. Configure the language menu whitelist

Each app chooses which languages appear in the picker:

```swift
import LocalizationKit

let configuration = LanguageMenuConfiguration(
    menuWhitelist: [.korean, .english, .japanese],
    fallbackLanguage: .english
)
```

### 2. Create a shared language manager

```swift
@MainActor
let languageManager = LanguageManager(
    defaultsKey: "app.languagePreference",
    configuration: configuration
)
```

### 3. Wire SwiftUI environment

```swift
ContentView()
    .environment(\.locale, languageManager.locale)
    .environmentObject(languageManager)
```

### 4. Look up localized strings

Use `LocalizationLookup` when the in-app language can differ from the system language:

```swift
let lookup = LocalizationLookup(
    bundle: .module,
    languageManager: languageManager,
    table: "Localizable"
)

let title = lookup.trSync("settings.title")
```

Kit UI strings (language menu labels) ship in `LocalizationUI.strings` and are available via `LocalizationLookup.kitUI(languageManager:)`.

### 5. Add the language menu button

```swift
// Toolbar icon (default)
LanguageMenuButton(languageManager: languageManager)

// Form / List label showing the current preference
LanguageMenuButton(languageManager: languageManager, style: .menuLabel)
```

`LanguageMenuButtonStyle.toolbarIcon` keeps a globe-only control for toolbars.
`LanguageMenuButtonStyle.menuLabel` shows the current choice (`Use System Language` or a language display name); platform `Menu` chrome may supply a trailing chevron—do not add one manually unless a target OS omits it.

## Features

- **AppLocalizationConfiguration** — bundles `defaultsKey` + menu whitelist with factory helpers
- **LocalizedModule** — one-time module registration protocol
- **ModuleL10n** / **L10nNamespace** — app/module string lookup without custom facades
- **AppLanguage** — ~42 language catalog with locale matching and system-language resolution
- **LanguagePreference** — `system` or explicit language, with legacy value migration
- **LanguageMenuConfiguration** — per-app whitelist and fallback policy
- **LocalizationLookup** — explicit `lproj` bundle selection for SPM modules
- **LanguageMenuButton** / **LanguageMenuButtonStyle** — globe toolbar or Form label menu
- **LocalizationDiagnostics** — DEBUG logging for invalid preferences (with suggestions)

## License

MIT — see [LICENSE.md](LICENSE.md).
