//
//  NetworkErrorTests.swift
//  StockScreenerAppTests
//
//  Created on 2/11/26.
//

import XCTest
@testable import StockScreenerApp

final class NetworkErrorTests: XCTestCase {
    
    func testErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.localizedDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.invalidResponse.localizedDescription, "Invalid response from server")
        XCTAssertEqual(NetworkError.noData.localizedDescription, "No data received")
        XCTAssertEqual(NetworkError.decodingError.localizedDescription, "Failed to decode response")
        XCTAssertEqual(NetworkError.rateLimitExceeded.localizedDescription, "Rate limit exceeded. Please wait before making more requests.")
        XCTAssertEqual(NetworkError.unauthorized.localizedDescription, "Invalid API key. Please check your configuration.")
    }
    
    func testServerErrorDescription() {
        let error = NetworkError.serverError(statusCode: 404)
        XCTAssertEqual(error.localizedDescription, "Server error with status code: 404")
    }
    
    func testAPIErrorDescription() {
        let error = NetworkError.apiError(message: "Custom API error")
        XCTAssertEqual(error.localizedDescription, "Custom API error")
    }
    
    func testUnknownErrorDescription() {
        let underlyingError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = NetworkError.unknown(underlyingError)
        XCTAssertTrue(error.localizedDescription.contains("Test error"))
    }
    
    func testAlphaVantageErrorResponseDecoding() throws {
        let json = """
        {
            "Error Message": "Invalid API call",
            "Information": "Please check your request",
            "Note": "API rate limit exceeded"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(AlphaVantageErrorResponse.self, from: data)
        
        XCTAssertEqual(response.errorMessage, "Invalid API call")
        XCTAssertEqual(response.information, "Please check your request")
        XCTAssertEqual(response.note, "API rate limit exceeded")
    }
    
    func testAlphaVantageErrorResponsePartialData() throws {
        let json = """
        {
            "Note": "Rate limit exceeded"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(AlphaVantageErrorResponse.self, from: data)
        
        XCTAssertNil(response.errorMessage)
        XCTAssertNil(response.information)
        XCTAssertEqual(response.note, "Rate limit exceeded")
    }
}
