# StockScreener iOS App

A modern iOS stock screening application featuring real-time market data, watchlists, and comprehensive stock analysis.

## Current Features

- ✅ Welcome/Onboarding screen
- 🎨 Custom color scheme with dark green theme
- 📱 Storyboard-based UI

## Project Structure

```
StockScreenerApp/
├── Application/           # App lifecycle
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── SceneDelegateExtensions.swift
├── Core/                  # Constants and utilities
│   ├── Constants.swift
│   └── Extensions/
│       └── UIColor+Extensions.swift
├── Presentation/          # UI layer
│   └── Scenes/
│       └── Onboarding/
│           └── WelcomeViewController.swift
└── Resources/
    ├── Assets.xcassets
    ├── Base.lproj
    └── Info.plist
```

## Setup

1. Open `StockScreenerApp.xcodeproj` in Xcode
2. Build and run (`⌘R`)

## Design System

**Colors:**
- Primary: `#13ec80` (Emerald Green)
- Background: `#102219` (Dark Green)
- Text Secondary: `#92c9ad` (Light Green)

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## License

Private project - All rights reserved
