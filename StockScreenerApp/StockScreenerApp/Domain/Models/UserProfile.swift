//
//  UserProfile.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation

struct UserProfile: Codable {
    let id: String
    var name: String
    var email: String
    var profileImagePath: String?
    let createdAt: Date
    
    init(name: String, email: String, profileImagePath: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.profileImagePath = profileImagePath
        self.createdAt = Date()
    }
    
    var displayName: String {
        return name.isEmpty ? email : name
    }
    
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return String(email.prefix(2)).uppercased()
    }
}
