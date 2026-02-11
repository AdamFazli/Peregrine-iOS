//
//  WatchlistRepository.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation

class WatchlistRepository {
    static let shared = WatchlistRepository()
    
    private let fileName = "watchlist.json"
    private let fileManager = FileManager.default
    
    private var fileURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private init() {}
    
    func save(stock: Stock) throws {
        var stocks = try getAll()
        
        if !stocks.contains(where: { $0.symbol == stock.symbol }) {
            stocks.append(stock)
            try saveStocks(stocks)
        }
    }
    
    func remove(stock: Stock) throws {
        var stocks = try getAll()
        stocks.removeAll { $0.symbol == stock.symbol }
        try saveStocks(stocks)
    }
    
    func getAll() throws -> [Stock] {
        guard let fileURL = fileURL else {
            throw WatchlistError.fileURLNotFound
        }
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        let stocks = try JSONDecoder().decode([Stock].self, from: data)
        return stocks
    }
    
    func contains(symbol: String) throws -> Bool {
        let stocks = try getAll()
        return stocks.contains { $0.symbol == symbol }
    }
    
    private func saveStocks(_ stocks: [Stock]) throws {
        guard let fileURL = fileURL else {
            throw WatchlistError.fileURLNotFound
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(stocks)
        try data.write(to: fileURL, options: [.atomic])
    }
}

enum WatchlistError: Error, LocalizedError {
    case fileURLNotFound
    
    var errorDescription: String? {
        switch self {
        case .fileURLNotFound:
            return "Could not locate documents directory"
        }
    }
}
