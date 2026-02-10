//
//  SearchViewModel.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [Stock] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager? = nil) {
        self.networkManager = networkManager ?? NetworkManager.shared
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                Task {
                    await self?.performSearch(query: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(query: String) async {
        guard !query.isEmpty else {
            results = []
            errorMessage = nil
            return
        }
        
        guard query.count >= 1 else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: SearchResponse = try await networkManager.fetch(
                endpoint: StockEndpoint.search(keywords: query)
            )
            results = response.bestMatches
            isLoading = false
        } catch let error as NetworkError {
            switch error {
            case .rateLimitExceeded:
                errorMessage = "Rate limit exceeded. Please wait a moment."
            case .invalidURL:
                errorMessage = "Invalid request URL"
            case .noData:
                errorMessage = "No data received from server"
            case .decodingError:
                errorMessage = "Failed to process server response"
            case .serverError(let code):
                errorMessage = "Server error (Code: \(code))"
            default:
                errorMessage = error.localizedDescription
            }
            isLoading = false
        } catch {
            errorMessage = "An unexpected error occurred"
            isLoading = false
        }
    }
    
    func clearSearch() {
        searchText = ""
        results = []
        errorMessage = nil
    }
}
