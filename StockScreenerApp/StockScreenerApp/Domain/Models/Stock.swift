//
//  Stock.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

struct Stock: Decodable, Identifiable {
    let symbol: String
    let name: String
    let type: String
    let region: String
    
    var id: String { symbol }
    
    var displayType: String {
        switch type.lowercased() {
        case "equity":
            return "Stock"
        case "etf":
            return "ETF"
        case "crypto":
            return "Crypto"
        default:
            return type
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case region = "4. region"
    }
}

struct SearchResponse: Decodable {
    let bestMatches: [Stock]
}
