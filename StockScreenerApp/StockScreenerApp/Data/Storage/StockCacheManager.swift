//
//  StockCacheManager.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation

class StockCacheManager {
    static let shared = StockCacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsDirectory.appendingPathComponent("StockCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Stock Detail Caching
    
    func cacheStockDetail(_ detail: CachedStockDetail, for symbol: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(symbol)_detail.json")
        
        do {
            let data = try JSONEncoder().encode(detail)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
    }
    
    func getCachedStockDetail(for symbol: String) -> CachedStockDetail? {
        let fileURL = cacheDirectory.appendingPathComponent("\(symbol)_detail.json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cached = try JSONDecoder().decode(CachedStockDetail.self, from: data)
            
            // Check if cache is still valid (24 hours)
            if Date().timeIntervalSince(cached.cachedAt) < 86400 {
                return cached
            } else {
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Stock History Caching
    
    func cacheStockHistory(_ history: CachedStockHistory, for symbol: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(symbol)_history.json")
        
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
    }
    
    func getCachedStockHistory(for symbol: String) -> CachedStockHistory? {
        let fileURL = cacheDirectory.appendingPathComponent("\(symbol)_history.json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cached = try JSONDecoder().decode(CachedStockHistory.self, from: data)
            
            if Date().timeIntervalSince(cached.cachedAt) < 86400 {
                return cached
            } else {
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Clear Cache
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getCacheSize() -> String {
        var totalSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
}

// MARK: - Cached Models

struct CachedStockDetail: Codable {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: String
    let high: Double
    let low: Double
    let open: Double
    let previousClose: Double
    let volume: String
    let cachedAt: Date
    
    init(from detail: StockDetail) {
        self.symbol = detail.symbol
        self.price = detail.price
        self.change = detail.change
        self.changePercent = detail.changePercent
        self.high = detail.high
        self.low = detail.low
        self.open = detail.open
        self.previousClose = detail.previousClose
        self.volume = detail.volume
        self.cachedAt = Date()
    }
    
    func toStockDetail() -> StockDetail? {
        let json: [String: Any] = [
            "01. symbol": symbol,
            "05. price": String(price),
            "09. change": String(change),
            "10. change percent": changePercent,
            "03. high": String(high),
            "04. low": String(low),
            "02. open": String(open),
            "08. previous close": String(previousClose),
            "06. volume": volume
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        return try? JSONDecoder().decode(StockDetail.self, from: data)
    }
}

struct CachedStockHistory: Codable {
    let symbol: String
    let prices: [Double]
    let cachedAt: Date
    
    init(symbol: String, prices: [Double]) {
        self.symbol = symbol
        self.prices = prices
        self.cachedAt = Date()
    }
}
