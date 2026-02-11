//
//  WatchlistRepositoryTests.swift
//  StockScreenerAppTests
//
//  Created on 2/11/26.
//

import XCTest
@testable import StockScreenerApp

final class WatchlistRepositoryTests: XCTestCase {
    
    var repository: WatchlistRepository!
    var testStock1: Stock!
    var testStock2: Stock!
    
    override func setUp() {
        super.setUp()
        repository = WatchlistRepository.shared
        
        testStock1 = Stock(
            symbol: "AAPL",
            name: "Apple Inc.",
            type: "Equity",
            region: "United States"
        )
        
        testStock2 = Stock(
            symbol: "GOOGL",
            name: "Alphabet Inc.",
            type: "Equity",
            region: "United States"
        )
        
        try? repository.getAll().forEach { stock in
            try? repository.remove(stock: stock)
        }
    }
    
    override func tearDown() {
        try? repository.getAll().forEach { stock in
            try? repository.remove(stock: stock)
        }
        super.tearDown()
    }
    
    func testSaveStock() throws {
        try repository.save(stock: testStock1)
        
        let stocks = try repository.getAll()
        XCTAssertEqual(stocks.count, 1)
        XCTAssertEqual(stocks.first?.symbol, "AAPL")
    }
    
    func testSaveDuplicateStock() throws {
        try repository.save(stock: testStock1)
        try repository.save(stock: testStock1)
        
        let stocks = try repository.getAll()
        XCTAssertEqual(stocks.count, 1, "Should not save duplicate stocks")
    }
    
    func testSaveMultipleStocks() throws {
        try repository.save(stock: testStock1)
        try repository.save(stock: testStock2)
        
        let stocks = try repository.getAll()
        XCTAssertEqual(stocks.count, 2)
    }
    
    func testRemoveStock() throws {
        try repository.save(stock: testStock1)
        try repository.save(stock: testStock2)
        
        try repository.remove(stock: testStock1)
        
        let stocks = try repository.getAll()
        XCTAssertEqual(stocks.count, 1)
        XCTAssertEqual(stocks.first?.symbol, "GOOGL")
    }
    
    func testRemoveNonExistentStock() throws {
        try repository.save(stock: testStock1)
        
        try repository.remove(stock: testStock2)
        
        let stocks = try repository.getAll()
        XCTAssertEqual(stocks.count, 1, "Should not affect other stocks")
    }
    
    func testGetAllEmpty() throws {
        let stocks = try repository.getAll()
        XCTAssertEqual(stocks.count, 0)
    }
    
    func testContainsSymbol() throws {
        try repository.save(stock: testStock1)
        
        XCTAssertTrue(try repository.contains(symbol: "AAPL"))
        XCTAssertFalse(try repository.contains(symbol: "GOOGL"))
    }
    
    func testPersistence() throws {
        try repository.save(stock: testStock1)
        
        let newRepository = WatchlistRepository.shared
        let stocks = try newRepository.getAll()
        
        XCTAssertEqual(stocks.count, 1)
        XCTAssertEqual(stocks.first?.symbol, "AAPL")
    }
}
