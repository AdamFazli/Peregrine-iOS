//
//  NetworkError.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

// MARK: - Network Errors

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case rateLimitExceeded
    case unauthorized
    case serverError(statusCode: Int)
    case apiError(message: String)
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
        case .unauthorized:
            return "Invalid API key. Please check your configuration."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .apiError(let message):
            return message
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Alpha Vantage Error Response

struct AlphaVantageErrorResponse: Decodable {
    let errorMessage: String?
    let information: String?
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "Error Message"
        case information = "Information"
        case note = "Note"
    }
}
