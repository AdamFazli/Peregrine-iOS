//
//  NetworkError.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait before making more requests."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
