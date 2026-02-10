//
//  StockEndpoint.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

enum StockEndpoint: Endpoint {
    case quote(symbol: String)
    case search(keywords: String)
    case timeSeries(symbol: String, interval: String)
    
    var path: String {
        return ""
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .quote(let symbol):
            return [
                URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
                URLQueryItem(name: "symbol", value: symbol)
            ]
            
        case .search(let keywords):
            return [
                URLQueryItem(name: "function", value: "SYMBOL_SEARCH"),
                URLQueryItem(name: "keywords", value: keywords)
            ]
            
        case .timeSeries(let symbol, let interval):
            return [
                URLQueryItem(name: "function", value: "TIME_SERIES_INTRADAY"),
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "interval", value: interval)
            ]
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
