# StockScreener iOS App

A modern iOS stock screening application built with **Clean Architecture** and **MVVM** pattern, featuring real-time market data, authentication, watchlists, and comprehensive stock analysis with smooth animations and interactive charts.

## Features

### Core Features
- ✅ **Authentication Flow** - Login and registration with profile image support
- ✅ **Home Dashboard** - Market overview with top movers and recently viewed stocks
- ✅ **Stock Search** - Real-time search with debounced input and instant results
- ✅ **Stock Details** - Live price updates, interactive charts, and key statistics
- ✅ **Watchlist** - Add/remove stocks with swipe actions, real-time prices, and persistent storage
- ✅ **Interactive Charts** - Line charts with monthly historical data and 6 time periods (1D, 1W, 1M, 3M, 1Y, ALL)
- ✅ **Settings** - Language selection, notifications, cache management, and account options
- ✅ **Welcome Screen** - Branded onboarding experience with smooth navigation

### UI/UX Enhancements
- 🎨 **Smooth Animations**
  - Staggered fade-in for search results and watchlist items
  - Animated chart drawing with gradient fill
  - Bounce animation for star button (watchlist toggle)
  - Spring animations for card transitions
- 📊 **Time Period Selector** - Seamless switching between different chart timeframes
- 🔄 **Pull-to-Refresh** - Refresh data on all screens with custom styling
- 💫 **Loading States** - Activity indicators and skeleton screens
- 🎯 **Haptic Feedback** - Touch feedback for important user actions
- 📱 **Responsive Design** - Optimized layouts for all iPhone screen sizes
- 🌙 **Dark Theme** - Beautiful dark green color scheme throughout

### Technical Features
- ⚡ **API Rate Limiting** - Built-in throttling system (5 requests/60s)
- 🔒 **Error Handling** - Comprehensive error management with retry mechanisms
- 💾 **Local Persistence** - JSON-based storage for watchlist, cache, and user data
- 🏗️ **Clean Architecture** - Strict separation of Domain, Data, and Presentation layers
- 📐 **MVVM Pattern** - ViewModels handle business logic, Views handle UI
- 🔄 **Combine Framework** - Reactive programming for data binding
- 🎨 **Storyboards + Programmatic UI** - Hybrid approach for optimal development
- 📸 **Photo Library Integration** - Profile image selection with PHPicker and UIImagePicker

## Architecture Overview

The app follows **Clean Architecture** principles with **MVVM (Model-View-ViewModel)** pattern, ensuring clear separation of concerns, testability, and maintainability.

### Architecture Layers

```
┌─────────────────────────────────────────────┐
│         Presentation Layer (MVVM)           │
│  ViewControllers ↔ ViewModels ↔ Models     │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│            Domain Layer                     │
│  Business Models & Use Cases                │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│             Data Layer                      │
│  Network Manager ↔ Repositories ↔ Storage  │
└─────────────────────────────────────────────┘
```

### Project Structure

```
StockScreenerApp/
├── Application/                    # App lifecycle and configuration
│   ├── AppDelegate.swift          # App initialization
│   ├── SceneDelegate.swift        # Window/scene management
│   └── SceneDelegateExtensions.swift  # Navigation flow logic
│
├── Core/                          # Shared utilities and constants
│   ├── Constants.swift            # App-wide constants (UI, Keys)
│   └── Extensions/
│       └── UIColor+Extensions.swift  # Hex color support
│
├── Domain/                        # Business logic layer
│   └── Models/
│       ├── StockModels.swift     # Stock, StockDetail, StockHistory, TimePeriod
│       └── UserProfile.swift     # User authentication models
│
├── Data/                          # Data management layer
│   ├── Network/                   # API communication
│   │   ├── APIService.swift      # Endpoint definitions
│   │   ├── NetworkManager.swift  # HTTP client with URLSession
│   │   ├── NetworkError.swift    # Error handling
│   │   └── Throttler.swift       # Rate limiting (Actor-based)
│   └── Storage/                   # Local persistence
│       ├── WatchlistRepository.swift     # Watchlist CRUD
│       ├── StockCacheManager.swift       # Stock data caching
│       ├── RecentlyViewedManager.swift   # Recently viewed stocks
│       ├── AuthManager.swift             # Mock authentication
│       └── ProfileImageManager.swift     # Profile image storage
│
├── Presentation/                  # UI layer (MVVM)
│   ├── MainTabBarController.swift        # Tab navigation
│   ├── Components/                        # Reusable UI components
│   │   ├── SimpleLineChartView.swift     # Custom chart view
│   │   ├── DashboardView.swift           # Dashboard components
│   │   └── StockCell.swift               # Stock list cell
│   └── Scenes/                            # Feature screens
│       ├── Onboarding/
│       │   └── WelcomeViewController.swift
│       ├── Auth/
│       │   ├── LoginViewController.swift
│       │   └── RegisterViewController.swift
│       ├── Home/
│       │   ├── HomeViewController.swift
│       │   └── HomeViewModel.swift
│       ├── Search/
│       │   ├── SearchViewController.swift
│       │   └── SearchViewModel.swift
│       ├── StockDetail/
│       │   ├── StockDetailViewController.swift
│       │   └── StockDetailViewModel.swift
│       ├── Watchlist/
│       │   ├── WatchlistViewController.swift
│       │   └── WatchlistStockCell.swift
│       └── Settings/
│           ├── SettingsViewController.swift
│           └── SettingsViewModel.swift
│
└── Resources/
    ├── Assets.xcassets            # Images and colors
    ├── Base.lproj/
    │   └── Main.storyboard        # UI layouts (Auth, Settings, Watchlist)
    └── Info.plist                 # App configuration
```

### Key Design Patterns

1. **MVVM (Model-View-ViewModel)**
   - **View**: UIViewController handles UI and user interactions
   - **ViewModel**: Contains business logic and state management
   - **Model**: Pure data structures (Codable)
   - **Binding**: Combine framework with `@Published` properties

2. **Repository Pattern**
   - Abstract data sources (API, local storage)
   - Single source of truth for data operations
   - Examples: `WatchlistRepository`, `StockCacheManager`

3. **Dependency Injection**
   - ViewModels receive dependencies through initializers
   - Enables easy testing and mocking

4. **Protocol-Oriented**
   - `Endpoint` protocol for API definitions
   - Clean separation of concerns

5. **Actor-Based Concurrency**
   - `Throttler` uses Swift Actor for thread-safe rate limiting
   - Async/await for network operations

## Setup Instructions

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later
- iOS Simulator (iPhone 15 recommended) or physical iOS device
- AlphaVantage API key (already configured)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd "Stock Screener App"
   ```

2. **Open the project**
   ```bash
   open StockScreenerApp/StockScreenerApp.xcodeproj
   ```

3. **Configure API Key** (Optional - Already Set)
   - Navigate to `StockScreenerApp/Data/Network/APIService.swift`
   - Replace the API key if needed:
     ```swift
     static let apiKey = "YOUR_API_KEY_HERE"
     ```
   - Get a free API key at [AlphaVantage](https://www.alphavantage.co/support/#api-key)

4. **Select a simulator**
   - Choose iPhone 15 or any iOS 15.0+ device from the scheme selector

5. **Build and run**
   - Press `⌘R` or click the Run button
   - App will launch with the Welcome screen

6. **Run tests** (Optional)
   - Press `⌘U` to run unit tests
   - Tests cover ViewModels, repositories, and business logic

### First Run Experience

1. **Welcome Screen** → Tap "Get Started"
2. **Login Screen** → Tap "Register" to create an account
3. **Register Screen** → Fill in details (optional profile photo)
4. **Login** → Use your registered credentials
5. **Home Dashboard** → Explore the app!

### Important Notes

- **API Rate Limits**: Free tier allows 5 requests per minute
- **Rate Limit Handling**: App automatically handles rate limits with error messages and retry countdowns
- **Offline Cache**: Stock data is cached locally for offline viewing
- **Mock Authentication**: User accounts are stored locally (no backend required)

## Design System

**Colors:**
- Primary: `#13ec80` (Emerald Green)
- Background: `#102219` (Dark Green)
- Card Background: `#162b21` (Dark Green Card)
- Input Background: `#1c3328` (Dark Green Input)
- Text Secondary: `#92c9ad` (Light Green)

## API Reference

This app uses the [AlphaVantage API](https://www.alphavantage.co/) for real-time stock market data.

### Endpoints Used
- **SYMBOL_SEARCH** - Search stocks by keyword/symbol
- **GLOBAL_QUOTE** - Real-time stock price quotes (used for watchlist and stock details)
- **OVERVIEW** - Company fundamentals (market cap, P/E, dividend yield, 52-week range)
- **TIME_SERIES_MONTHLY** - Monthly historical price data for charts (as per requirement)

### Rate Limits
- **Free Tier**: 5 API calls per minute, 500 calls per day
- **Throttling**: Built-in throttler prevents exceeding rate limits
- **Error Handling**: Automatic retry with countdown when rate limit exceeded
- **Caching**: Recent data cached locally to reduce API calls
- **Watchlist Strategy**: Real prices fetched sequentially with delays to respect rate limits

## Technologies & Frameworks

- **Swift 5.7+** - Primary programming language
- **UIKit** - UI framework
- **Combine** - Reactive programming for data binding
- **URLSession** - Networking with async/await
- **Codable** - JSON parsing
- **Auto Layout** - Responsive UI layouts
- **Storyboards + Programmatic UI** - Hybrid approach
- **PHPicker/UIImagePicker** - Photo selection
- **FileManager** - Local data persistence
- **XCTest** - Unit testing framework

## Requirements

- **iOS**: 15.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **Device**: iPhone or iPad running iOS 15.0+
- **Internet**: Required for initial data fetch (cached data available offline)

## App Navigation Flow

```
Welcome Screen
    ↓
Login Screen ←→ Register Screen
    ↓
Main App (Tab Bar)
    ├── Home (Dashboard)
    │   ├── Market Overview
    │   ├── Top Movers
    │   └── Recently Viewed → Stock Detail
    │
    ├── Search
    │   └── Search Results → Stock Detail
    │
    ├── Watchlist
    │   └── Saved Stocks → Stock Detail
    │
    └── Settings
        ├── Preferences (Language, Notifications)
        ├── Data Management (Clear Cache)
        ├── Information (About, Privacy, Rate)
        └── Account (Log Out)
```

**Built using Clean Architecture and MVVM**

## Future Improvement Ideas

### High Priority Features
1. **Enhanced Offline Support**
   - Full offline mode with complete cached data
   - Background sync when network available
   - Offline indicators throughout the app
   - Queue API requests for when connection returns

2. **Real Backend Authentication**
   - Firebase/Supabase integration
   - Cloud sync for watchlist and preferences
   - OAuth support (Apple, Google)
   - Secure token management with Keychain

3. **Price Alerts & Notifications**
   - Set price target alerts for stocks
   - Push notifications for price changes
   - Daily market summary notifications
   - Configurable alert thresholds

4. **Portfolio Tracking**
   - Add stocks with purchase price and quantity
   - Real-time profit/loss calculations
   - Portfolio performance charts
   - Transaction history
   - Cost basis tracking

### Enhanced User Experience
5. **News Integration**
   - Latest news articles for each stock
   - News API integration (NewsAPI, Finnhub)
   - In-app article reader
   - News-based sentiment indicators

6. **Advanced Charting**
   - Candlestick charts with pinch-to-zoom
   - Technical indicators (MA, RSI, MACD, Bollinger Bands)
   - Volume bars
   - Drawing tools (trendlines, support/resistance)
   - Compare multiple stocks on one chart

7. **Social Features**
   - Share watchlists with friends
   - Follow other users' portfolios
   - Community stock discussions
   - Top trending stocks among users

### Technical Improvements
8. **Performance Optimizations**
   - Implement image caching with SDWebImage/Kingfisher
   - Add stock logos from Clearbit/Alpha Vantage
   - Pagination for search results
   - Background data refresh with BGTaskScheduler
   - Memory optimization for large datasets

9. **Enhanced Caching Strategy**
   - Core Data instead of JSON files
   - Intelligent cache invalidation
   - Compressed data storage
   - Configurable cache expiration times

10. **Testing & Quality**
    - Increase unit test coverage to 90%+
    - Add UI tests with XCTest
    - Integration tests for API layer
    - Snapshot tests for UI components
    - Performance tests for critical paths

### Business Features
11. **Premium Subscription**
    - Ad-free experience
    - Unlimited API calls (premium API tier)
    - Advanced analytics and insights
    - Export portfolio data to CSV/PDF
    - Priority customer support

12. **Internationalization**
    - Multi-language support (actual translations)
    - Region-specific stock exchanges
    - Currency conversion
    - Local market hours

13. **Widgets & Extensions**
    - Home screen widgets for watchlist
    - Today extension for quick stock lookup
    - Watch app for quick price checks
    - Siri shortcuts integration

### Data & Analytics
14. **Advanced Analytics**
    - Stock screener with custom filters
    - Fundamental analysis tools
    - Comparison tools (vs. sector, vs. market)
    - Historical performance analysis
    - Dividend calculator

15. **Market Data Enhancements**
    - Options chains
    - Crypto currency support
    - Forex pairs
    - Commodities and futures
    - Global market indices

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- AlphaVantage API key (free tier available)

## License

Private project - All rights reserved
