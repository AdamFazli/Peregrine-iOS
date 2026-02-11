//
//  APIService.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation

// MARK: - API Configuration

struct APIConstants {
    static let baseURL = "https://www.alphavantage.co/query"
    static let apiKey = "XZRTSS4010D491NR"
    
    static let requestsPerMinute = 5
    static let timeWindow: TimeInterval = 60
}

// MARK: - Endpoint Protocol

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension Endpoint {
    func makeURL() -> URL? {
        guard var components = URLComponents(string: APIConstants.baseURL) else {
            return nil
        }
        
        var items = queryItems
        items.append(URLQueryItem(name: "apikey", value: APIConstants.apiKey))
        components.queryItems = items
        
        return components.url
    }
}

// MARK: - Stock Endpoints

enum StockEndpoint: Endpoint {
    case quote(symbol: String)
    case search(keywords: String)
    case intradayTimeSeries(symbol: String)
    case dailyTimeSeries(symbol: String)
    case monthlyTimeSeries(symbol: String)
    
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
            
        case .intradayTimeSeries(let symbol):
            return [
                URLQueryItem(name: "function", value: "TIME_SERIES_INTRADAY"),
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "interval", value: "60min"),
                URLQueryItem(name: "outputsize", value: "full")
            ]
            
        case .dailyTimeSeries(let symbol):
            return [
                URLQueryItem(name: "function", value: "TIME_SERIES_DAILY"),
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "outputsize", value: "full")
            ]
            
        case .monthlyTimeSeries(let symbol):
            return [
                URLQueryItem(name: "function", value: "TIME_SERIES_MONTHLY"),
                URLQueryItem(name: "symbol", value: symbol)
            ]
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
