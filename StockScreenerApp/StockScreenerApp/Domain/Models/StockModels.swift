//
//  StockModels.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation

// MARK: - Stock (Search Results)

struct Stock: Codable, Identifiable, Equatable {
    let symbol: String
    let name: String
    let type: String
    let region: String
    
    var id: String { symbol }
    
    init(symbol: String, name: String, type: String, region: String) {
        self.symbol = symbol
        self.name = name
        self.type = type
        self.region = region
    }
    
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

// MARK: - StockDetail (Quote Data)

struct StockDetail: Decodable {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: String
    let high: Double
    let low: Double
    let open: Double
    let previousClose: Double
    let volume: String
    
    var isPositive: Bool {
        return change >= 0
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedChange: String {
        let sign = isPositive ? "+" : ""
        return String(format: "%@$%.2f", sign, change)
    }
    
    var formattedChangePercent: String {
        let percentValue = changePercent.replacingOccurrences(of: "%", with: "")
        let sign = changePercent.contains("-") ? "" : "+"
        return "\(sign)\(percentValue)%"
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
        case high = "03. high"
        case low = "04. low"
        case open = "02. open"
        case previousClose = "08. previous close"
        case volume = "06. volume"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        
        let priceString = try container.decode(String.self, forKey: .price)
        price = Double(priceString) ?? 0.0
        
        let changeString = try container.decode(String.self, forKey: .change)
        change = Double(changeString) ?? 0.0
        
        changePercent = try container.decode(String.self, forKey: .changePercent)
        
        let highString = try container.decode(String.self, forKey: .high)
        high = Double(highString) ?? 0.0
        
        let lowString = try container.decode(String.self, forKey: .low)
        low = Double(lowString) ?? 0.0
        
        let openString = try container.decode(String.self, forKey: .open)
        open = Double(openString) ?? 0.0
        
        let prevCloseString = try container.decode(String.self, forKey: .previousClose)
        previousClose = Double(prevCloseString) ?? 0.0
        
        volume = try container.decode(String.self, forKey: .volume)
    }
}

struct QuoteResponse: Decodable {
    let globalQuote: StockDetail
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

// MARK: - StockHistory (Time Series Data)

enum TimePeriod: String, CaseIterable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case year = "1Y"
    case all = "ALL"
}

struct StockHistory: Decodable {
    let metaData: MetaData
    let timeSeries: [String: TimeSeriesData]
    
    var prices: [Double] {
        let sortedDates = timeSeries.keys.sorted()
        return sortedDates.compactMap { timeSeries[$0]?.close }
    }
    
    func pricesForPeriod(_ period: TimePeriod) -> [Double] {
        let sortedDates = timeSeries.keys.sorted()
        let now = Date()
        
        let filteredDates: [String]
        switch period {
        case .day:
            filteredDates = sortedDates.filter { dateString in
                guard let date = parseDate(dateString) else { return false }
                return now.timeIntervalSince(date) <= 86400
            }
        case .week:
            filteredDates = sortedDates.filter { dateString in
                guard let date = parseDate(dateString) else { return false }
                return now.timeIntervalSince(date) <= 604800
            }
        case .month:
            filteredDates = sortedDates.filter { dateString in
                guard let date = parseDate(dateString) else { return false }
                return now.timeIntervalSince(date) <= 2592000
            }
        case .threeMonths:
            filteredDates = sortedDates.filter { dateString in
                guard let date = parseDate(dateString) else { return false }
                return now.timeIntervalSince(date) <= 7776000
            }
        case .year:
            filteredDates = sortedDates.filter { dateString in
                guard let date = parseDate(dateString) else { return false }
                return now.timeIntervalSince(date) <= 31536000
            }
        case .all:
            filteredDates = sortedDates
        }
        
        return filteredDates.compactMap { timeSeries[$0]?.close }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    var trend: PriceTrend {
        guard let first = prices.first, let last = prices.last else {
            return .neutral
        }
        return last > first ? .up : .down
    }
    
    enum PriceTrend {
        case up, down, neutral
    }
    
    struct MetaData: Decodable {
        let symbol: String
        
        enum CodingKeys: String, CodingKey {
            case symbol = "2. Symbol"
        }
    }
    
    struct TimeSeriesData: Decodable {
        let open: Double
        let high: Double
        let low: Double
        let close: Double
        let volume: String
        
        enum CodingKeys: String, CodingKey {
            case open = "1. open"
            case high = "2. high"
            case low = "3. low"
            case close = "4. close"
            case volume = "5. volume"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let openString = try container.decode(String.self, forKey: .open)
            open = Double(openString) ?? 0.0
            
            let highString = try container.decode(String.self, forKey: .high)
            high = Double(highString) ?? 0.0
            
            let lowString = try container.decode(String.self, forKey: .low)
            low = Double(lowString) ?? 0.0
            
            let closeString = try container.decode(String.self, forKey: .close)
            close = Double(closeString) ?? 0.0
            
            volume = try container.decode(String.self, forKey: .volume)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metaData = try container.decode(MetaData.self, forKey: .metaData)
        
        if let monthly = try? container.decode([String: TimeSeriesData].self, forKey: .monthlyTimeSeries) {
            timeSeries = monthly
        } else if let daily = try? container.decode([String: TimeSeriesData].self, forKey: .dailyTimeSeries) {
            timeSeries = daily
        } else if let intraday = try? container.decode([String: TimeSeriesData].self, forKey: .intradayTimeSeries) {
            timeSeries = intraday
        } else {
            timeSeries = [:]
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case monthlyTimeSeries = "Monthly Time Series"
        case dailyTimeSeries = "Time Series (Daily)"
        case intradayTimeSeries = "Time Series (60min)"
    }
}
