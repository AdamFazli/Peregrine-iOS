//
//  StockDetailViewModel.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation
import Combine

@MainActor
class StockDetailViewModel: ObservableObject {
    @Published var stockDetail: StockDetail?
    @Published var stockHistory: StockHistory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var retryCountdown: Int = 0
    
    private let networkManager: NetworkManager
    private var retryTimer: Timer?
    let symbol: String
    
    init(symbol: String, networkManager: NetworkManager? = nil, stock: Stock? = nil) {
        self.symbol = symbol
        self.networkManager = networkManager ?? NetworkManager.shared
        
        if let stock = stock {
            RecentlyViewedManager.shared.addStock(stock)
        }
    }
    
    deinit {
        retryTimer?.invalidate()
    }
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        retryCountdown = 0
        retryTimer?.invalidate()
        
        do {
            let quoteResponse: QuoteResponse = try await networkManager.fetch(endpoint: StockEndpoint.quote(symbol: symbol))
            let history: StockHistory = try await networkManager.fetch(endpoint: StockEndpoint.monthlyTimeSeries(symbol: symbol))
            
            self.stockDetail = quoteResponse.globalQuote
            self.stockHistory = history
            self.isLoading = false
            
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            errorMessage = "An unexpected error occurred"
            isLoading = false
        }
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .rateLimitExceeded:
            errorMessage = "Rate limit exceeded. Please wait 60 seconds."
            startRetryCountdown(from: 60)
        case .unauthorized:
            errorMessage = "Invalid API key. Please check your configuration."
        case .decodingError:
            errorMessage = "Failed to load stock data. Please try again."
        case .apiError(let message):
            errorMessage = message
        default:
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func startRetryCountdown(from seconds: Int) {
        retryCountdown = seconds
        retryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                self.retryCountdown -= 1
                
                if self.retryCountdown <= 0 {
                    self.retryTimer?.invalidate()
                    self.retryTimer = nil
                    self.errorMessage = nil
                }
            }
        }
    }
}
