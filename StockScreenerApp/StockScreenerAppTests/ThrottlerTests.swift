//
//  ThrottlerTests.swift
//  StockScreenerAppTests
//
//  Created on 2/11/26.
//

import XCTest
@testable import StockScreenerApp

final class ThrottlerTests: XCTestCase {
    
    var throttler: Throttler!
    
    override func setUp() async throws {
        try await super.setUp()
        throttler = Throttler()
        await throttler.reset()
    }
    
    func testInitialRequestsAllowed() async throws {
        for _ in 0..<5 {
            try await throttler.checkAndRecordRequest()
        }
        
        let remaining = await throttler.remainingRequests()
        XCTAssertEqual(remaining, 0, "Should have 0 remaining requests after 5 requests")
    }
    
    func testRateLimitExceeded() async throws {
        for _ in 0..<5 {
            try await throttler.checkAndRecordRequest()
        }
        
        do {
            try await throttler.checkAndRecordRequest()
            XCTFail("Should throw rate limit exceeded error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.rateLimitExceeded)
        }
    }
    
    func testRemainingRequests() async throws {
        let initial = await throttler.remainingRequests()
        XCTAssertEqual(initial, 5)
        
        try await throttler.checkAndRecordRequest()
        let afterFirst = await throttler.remainingRequests()
        XCTAssertEqual(afterFirst, 4)
        
        try await throttler.checkAndRecordRequest()
        let afterSecond = await throttler.remainingRequests()
        XCTAssertEqual(afterSecond, 3)
    }
    
    func testReset() async throws {
        for _ in 0..<5 {
            try await throttler.checkAndRecordRequest()
        }
        
        let beforeReset = await throttler.remainingRequests()
        XCTAssertEqual(beforeReset, 0)
        
        await throttler.reset()
        
        let afterReset = await throttler.remainingRequests()
        XCTAssertEqual(afterReset, 5)
    }
    
    func testTimeWindowExpiry() async throws {
        let shortThrottler = Throttler(maxRequests: 2, timeWindow: 1.0)
        
        try await shortThrottler.checkAndRecordRequest()
        try await shortThrottler.checkAndRecordRequest()
        
        let beforeWait = await shortThrottler.remainingRequests()
        XCTAssertEqual(beforeWait, 0)
        
        try await Task.sleep(nanoseconds: 1_100_000_000)
        
        let remaining = await shortThrottler.remainingRequests()
        XCTAssertGreaterThan(remaining, 0, "Requests should be available after time window")
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.decodingError, .decodingError),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.unauthorized, .unauthorized):
            return true
        case (.serverError(let code1), .serverError(let code2)):
            return code1 == code2
        case (.apiError(let msg1), .apiError(let msg2)):
            return msg1 == msg2
        default:
            return false
        }
    }
}
