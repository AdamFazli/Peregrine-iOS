//
//  RecentlyViewedManager.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation

class RecentlyViewedManager {
    static let shared = RecentlyViewedManager()
    
    private let fileName = "recent_stocks.json"
    private let maxRecentStocks = 10
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private init() {}
    
    func addStock(_ stock: Stock) {
        do {
            var recentStocks = try getAll()
            
            if let existingIndex = recentStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                recentStocks.remove(at: existingIndex)
            }
            
            recentStocks.insert(stock, at: 0)
            
            if recentStocks.count > maxRecentStocks {
                recentStocks = Array(recentStocks.prefix(maxRecentStocks))
            }
            
            let data = try JSONEncoder().encode(recentStocks)
            try data.write(to: fileURL, options: [.atomic])
            
        } catch {
            print("Error adding to recently viewed: \(error)")
        }
    }
    
    func getAll() throws -> [Stock] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        let stocks = try JSONDecoder().decode([Stock].self, from: data)
        return stocks
    }
    
    func clear() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
