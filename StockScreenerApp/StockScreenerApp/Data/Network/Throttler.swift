//
//  Throttler.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

actor Throttler {
    private var requestTimestamps: [Date] = []
    private let maxRequests: Int
    private let timeWindow: TimeInterval
    
    init(maxRequests: Int = 5, timeWindow: TimeInterval = 60) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }
    
    func checkAndRecordRequest() throws {
        let now = Date()
        
        requestTimestamps = requestTimestamps.filter { timestamp in
            now.timeIntervalSince(timestamp) < timeWindow
        }
        
        if requestTimestamps.count >= maxRequests {
            throw NetworkError.rateLimitExceeded
        }
        
        requestTimestamps.append(now)
    }
    
    func reset() {
        requestTimestamps.removeAll()
    }
    
    func remainingRequests() -> Int {
        let now = Date()
        let recentRequests = requestTimestamps.filter { timestamp in
            now.timeIntervalSince(timestamp) < timeWindow
        }
        return max(0, maxRequests - recentRequests.count)
    }
}
