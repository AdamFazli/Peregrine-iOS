//
//  SettingsViewModel.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
    }
    
    let availableLanguages = ["English", "Bahasa Malaysia", "中文"]
    
    let appVersion: String
    let buildNumber: String
    
    private let watchlistRepository = WatchlistRepository.shared
    private let recentlyViewedManager = RecentlyViewedManager.shared
    
    init() {
        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "English"
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        } else {
            self.appVersion = "1.0.0"
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.buildNumber = build
        } else {
            self.buildNumber = "1"
        }
    }
    
    func getCacheSize() -> String {
        do {
            let watchlistStocks = try watchlistRepository.getAll()
            let recentStocks = try recentlyViewedManager.getAll()
            let totalCount = watchlistStocks.count + recentStocks.count
            let estimatedSize = totalCount * 500
            
            if estimatedSize < 1024 {
                return "\(estimatedSize) B"
            } else if estimatedSize < 1024 * 1024 {
                return String(format: "%.1f KB", Double(estimatedSize) / 1024.0)
            } else {
                return String(format: "%.1f MB", Double(estimatedSize) / (1024.0 * 1024.0))
            }
        } catch {
            return "0 KB"
        }
    }
    
    func clearCache() throws {
        try watchlistRepository.clearAll()
        try recentlyViewedManager.clear()
    }
}
