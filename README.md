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
    .package(url: "https://github.com/deblur99/LocalizationKit", from: "1.0.0"),
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

## Quick start

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
LanguageMenuButton(languageManager: languageManager)
```

## Features

- **AppLanguage** — ~42 language catalog with locale matching and system-language resolution
- **LanguagePreference** — `system` or explicit language, with legacy value migration
- **LanguageMenuConfiguration** — per-app whitelist and fallback policy
- **LocalizationLookup** — explicit `lproj` bundle selection for SPM modules
- **LanguageMenuButton** — globe menu SwiftUI component
- **LocalizationDiagnostics** — DEBUG logging for invalid preferences (with suggestions)

## License

MIT — see [LICENSE.md](LICENSE.md).
