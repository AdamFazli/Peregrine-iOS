//
//  NetworkManager.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let throttler = Throttler()
    private let decoder: JSONDecoder
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: configuration)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        try await throttler.checkAndRecordRequest()
        
        guard let url = endpoint.makeURL() else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            if let apiError = try? JSONDecoder().decode(AlphaVantageErrorResponse.self, from: data) {
                if apiError.information?.lowercased().contains("invalid api key") == true
                    || apiError.information?.lowercased().contains("invalid api call") == true {
                    throw NetworkError.unauthorized
                }
                if apiError.information?.contains("rate limit") == true || apiError.information?.contains("25 requests") == true
                    || apiError.note?.contains("rate") == true || apiError.note?.contains("frequency") == true {
                    throw NetworkError.rateLimitExceeded
                }
                if let message = apiError.errorMessage ?? apiError.information ?? apiError.note {
                    throw NetworkError.apiError(message: message)
                }
            }
            
            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func remainingRequests() async -> Int {
        return await throttler.remainingRequests()
    }
    
    func resetThrottler() async {
        await throttler.reset()
    }
}
