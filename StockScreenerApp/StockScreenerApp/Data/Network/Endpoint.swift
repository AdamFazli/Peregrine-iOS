//
//  Endpoint.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension Endpoint {
    func makeURL() -> URL? {
        guard var components = URLComponents(string: APIConstants.baseURL) else {
            return nil
        }
        
        var items = queryItems
        items.append(URLQueryItem(name: "apikey", value: APIConstants.apiKey))
        components.queryItems = items
        
        return components.url
    }
}
