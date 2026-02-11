//
//  SearchViewModelTests.swift
//  StockScreenerAppTests
//
//  Created on 2/11/26.
//

import XCTest
import Combine
@testable import StockScreenerApp

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    var mockNetworkManager: MockNetworkManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = SearchViewModel(networkManager: mockNetworkManager)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchWithEmptyQuery() async {
        await viewModel.performSearch(query: "")
        
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSuccessfulSearch() async {
        let testStocks = [
            Stock(symbol: "AAPL", name: "Apple Inc.", type: "Equity", region: "US"),
            Stock(symbol: "GOOGL", name: "Alphabet Inc.", type: "Equity", region: "US")
        ]
        mockNetworkManager.mockSearchResult = SearchResponse(bestMatches: testStocks)
        
        await viewModel.performSearch(query: "AAPL")
        
        XCTAssertEqual(viewModel.results.count, 2)
        XCTAssertEqual(viewModel.results.first?.symbol, "AAPL")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchWithRateLimitError() async {
        mockNetworkManager.shouldThrowError = true
        mockNetworkManager.errorToThrow = NetworkError.rateLimitExceeded
        
        await viewModel.performSearch(query: "AAPL")
        
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "Rate limit exceeded. Please wait a moment.")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSearchWithNetworkError() async {
        mockNetworkManager.shouldThrowError = true
        mockNetworkManager.errorToThrow = NetworkError.invalidURL
        
        await viewModel.performSearch(query: "AAPL")
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testClearSearch() {
        viewModel.searchText = "AAPL"
        viewModel.results = [Stock(symbol: "AAPL", name: "Apple", type: "Equity", region: "US")]
        
        viewModel.clearSearch()
        
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadingStateToggle() async {
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await viewModel.performSearch(query: "AAPL")
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(loadingStates[0], false)
        XCTAssertEqual(loadingStates[1], true)
        XCTAssertEqual(loadingStates[2], false)
    }
}

class MockNetworkManager: NetworkManager {
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.unknown(NSError(domain: "test", code: -1))
    var mockSearchResult: SearchResponse?
    
    override init() {
        super.init()
    }
    
    override func fetch<T>(endpoint: Endpoint) async throws -> T where T : Decodable {
        if shouldThrowError {
            throw errorToThrow
        }
        
        if let result = mockSearchResult as? T {
            return result
        }
        
        throw NetworkError.noData
    }
}
