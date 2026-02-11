//
//  StockModelsTests.swift
//  StockScreenerAppTests
//
//  Created on 2/11/26.
//

import XCTest
@testable import StockScreenerApp

final class StockModelsTests: XCTestCase {
    
    func testStockDecoding() throws {
        let json = """
        {
            "1. symbol": "AAPL",
            "2. name": "Apple Inc.",
            "3. type": "Equity",
            "4. region": "United States"
        }
        """
        
        let data = json.data(using: .utf8)!
        let stock = try JSONDecoder().decode(Stock.self, from: data)
        
        XCTAssertEqual(stock.symbol, "AAPL")
        XCTAssertEqual(stock.name, "Apple Inc.")
        XCTAssertEqual(stock.type, "Equity")
        XCTAssertEqual(stock.region, "United States")
    }
    
    func testStockDisplayType() {
        let equityStock = Stock(symbol: "AAPL", name: "Apple", type: "Equity", region: "US")
        XCTAssertEqual(equityStock.displayType, "Stock")
        
        let etfStock = Stock(symbol: "SPY", name: "SPDR S&P 500", type: "ETF", region: "US")
        XCTAssertEqual(etfStock.displayType, "ETF")
        
        let cryptoStock = Stock(symbol: "BTC", name: "Bitcoin", type: "Crypto", region: "Global")
        XCTAssertEqual(cryptoStock.displayType, "Crypto")
    }
    
    func testStockEncoding() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", type: "Equity", region: "US")
        
        let data = try JSONEncoder().encode(stock)
        let decoded = try JSONDecoder().decode(Stock.self, from: data)
        
        XCTAssertEqual(decoded.symbol, stock.symbol)
        XCTAssertEqual(decoded.name, stock.name)
    }
    
    func testStockDetailFormatting() {
        let detail = createTestStockDetail(price: 150.25, change: 2.50, changePercent: "1.69%")
        
        XCTAssertEqual(detail.formattedPrice, "$150.25")
        XCTAssertEqual(detail.formattedChange, "+$2.50")
        XCTAssertEqual(detail.formattedChangePercent, "+1.69%")
        XCTAssertTrue(detail.isPositive)
    }
    
    func testStockDetailNegativeChange() {
        let detail = createTestStockDetail(price: 150.25, change: -2.50, changePercent: "-1.69%")
        
        XCTAssertEqual(detail.formattedChange, "$-2.50")
        XCTAssertEqual(detail.formattedChangePercent, "-1.69%")
        XCTAssertFalse(detail.isPositive)
    }
    
    func testStockHistoryPrices() {
        let history = createTestStockHistory()
        
        XCTAssertFalse(history.prices.isEmpty)
        XCTAssertGreaterThan(history.prices.count, 0)
    }
    
    func testStockHistoryTrend() {
        let upHistory = createTestStockHistory(startPrice: 100, endPrice: 150)
        XCTAssertEqual(upHistory.trend, .up)
        
        let downHistory = createTestStockHistory(startPrice: 150, endPrice: 100)
        XCTAssertEqual(downHistory.trend, .down)
    }
    
    private func createTestStockDetail(price: Double, change: Double, changePercent: String) -> StockDetail {
        let json = """
        {
            "01. symbol": "AAPL",
            "05. price": "\(price)",
            "09. change": "\(change)",
            "10. change percent": "\(changePercent)",
            "03. high": "151.00",
            "04. low": "149.00",
            "02. open": "150.00",
            "08. previous close": "147.75",
            "06. volume": "50000000"
        }
        """
        
        return try! JSONDecoder().decode(StockDetail.self, from: json.data(using: .utf8)!)
    }
    
    private func createTestStockHistory(startPrice: Double = 100, endPrice: Double = 150) -> StockHistory {
        let json = """
        {
            "Meta Data": {
                "2. Symbol": "AAPL"
            },
            "Monthly Time Series": {
                "2024-01-31": {
                    "1. open": "\(startPrice)",
                    "2. high": "\(startPrice + 5)",
                    "3. low": "\(startPrice - 5)",
                    "4. close": "\(startPrice)",
                    "5. volume": "1000000"
                },
                "2024-02-28": {
                    "1. open": "\(endPrice - 2)",
                    "2. high": "\(endPrice + 3)",
                    "3. low": "\(endPrice - 3)",
                    "4. close": "\(endPrice)",
                    "5. volume": "1200000"
                }
            }
        }
        """
        
        return try! JSONDecoder().decode(StockHistory.self, from: json.data(using: .utf8)!)
    }
}
