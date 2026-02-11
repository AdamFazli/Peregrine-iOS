# StockScreener iOS App

A modern iOS stock screening application featuring real-time market data, watchlists, and comprehensive stock analysis with smooth animations and interactive charts.

## Features

### Core Features
- ✅ **Stock Search** - Search stocks by symbol with debounced search
- ✅ **Stock Details** - Real-time price, market data, and key statistics
- ✅ **Watchlist** - Save and manage favorite stocks with local persistence
- ✅ **Interactive Charts** - Beautiful line charts with time period filters (1D, 1W, 1M, 3M, 1Y, ALL)
- ✅ **Welcome/Onboarding** - Custom onboarding screen with branded UI

### UI/UX Enhancements
- 🎨 **Smooth Animations**
  - Staggered fade-in for search results and watchlist items
  - Animated chart drawing with gradient fill
  - Bounce animation for star button (watchlist toggle)
  - Smooth transitions and spring animations
- 📊 **Time Period Selector** - Switch between different chart time periods seamlessly
- 🔄 **Pull-to-Refresh** - Refresh data on all screens
- 💫 **Loading States** - Activity indicators and animated transitions
- 🎯 **Haptic Feedback** - Touch feedback for important actions

### Technical Features
- ⚡ **API Rate Limiting** - Built-in throttling (5 requests/60s)
- 🔒 **Error Handling** - Graceful error messages with retry countdown
- 💾 **Local Persistence** - JSON-based watchlist storage
- 🧪 **Unit Tests** - Comprehensive test coverage for business logic
- 🏗️ **Clean Architecture** - MVVM pattern with clear separation of concerns

## Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
StockScreenerApp/
├── Application/              # App lifecycle
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── SceneDelegateExtensions.swift
├── Core/                     # Constants and utilities
│   ├── Constants.swift
│   └── Extensions/
│       └── UIColor+Extensions.swift
├── Domain/                   # Business logic
│   └── Models/
│       └── StockModels.swift (Stock, StockDetail, StockHistory, TimePeriod)
├── Data/                     # Data layer
│   ├── Network/
│   │   ├── APIService.swift
│   │   ├── NetworkManager.swift
│   │   ├── NetworkError.swift
│   │   └── Throttler.swift
│   └── Storage/
│       └── WatchlistRepository.swift
├── Presentation/             # UI layer (MVVM)
│   ├── MainTabBarController.swift
│   ├── Components/
│   │   ├── SimpleLineChartView.swift
│   │   └── StockCell.swift
│   └── Scenes/
│       ├── Onboarding/
│       │   └── WelcomeViewController.swift
│       ├── Search/
│       │   ├── SearchViewController.swift
│       │   └── SearchViewModel.swift
│       ├── StockDetail/
│       │   ├── StockDetailViewController.swift
│       │   └── StockDetailViewModel.swift
│       └── Watchlist/
│           └── WatchlistViewController.swift
└── Resources/
    ├── Assets.xcassets
    ├── Base.lproj
    └── Info.plist
```

## Setup

1. Clone the repository
2. Open `StockScreenerApp.xcodeproj` in Xcode
3. Your AlphaVantage API key is already configured in `Data/Network/APIService.swift`
4. Build and run (`⌘R`)
5. Run tests (`⌘U`)

**Note:** The app uses the AlphaVantage free tier with 5 API calls per minute. To test extensively, wait between searches or consider upgrading your API plan.

### 📚 Documentation

- [`FEATURES.md`](FEATURES.md) - Complete feature documentation & animations ✨

## Design System

**Colors:**
- Primary: `#13ec80` (Emerald Green)
- Background: `#102219` (Dark Green)
- Text Secondary: `#92c9ad` (Light Green)

## API

This app uses the [AlphaVantage API](https://www.alphavantage.co/) for stock data:
- **SYMBOL_SEARCH** - Search stocks by keyword
- **GLOBAL_QUOTE** - Real-time stock quotes
- **TIME_SERIES_INTRADAY** - Hourly price data (for 1D period)
- **TIME_SERIES_DAILY** - Daily price data (for 1W, 1M periods)
- **TIME_SERIES_MONTHLY** - Monthly price data (for 3M, 1Y, ALL periods)

**Rate Limits:** 5 API calls per minute (free tier)

## Future Improvements

### Planned Features
- 📴 **Offline Support** - Cache stock data for offline viewing
- 🔔 **Price Alerts** - Push notifications for price changes
- 📈 **Portfolio Tracking** - Track stock holdings and P&L
- 🔐 **Authentication** - User accounts with cloud sync
- 🌐 **News Integration** - Latest news for each stock
- 📊 **Advanced Charts** - Candlestick charts, technical indicators

### Performance Optimizations
- Implement network response caching
- Image caching for stock logos
- Background data refresh
- Pagination for large datasets

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- AlphaVantage API key (free tier available)

## License

Private project - All rights reserved
