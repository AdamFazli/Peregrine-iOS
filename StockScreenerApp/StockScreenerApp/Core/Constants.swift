//
//  Constants.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import Foundation
import UIKit

enum Constants {
    
    // MARK: - UI Constants
    enum UI {
        enum Colors {
            static let primary = UIColor(hex: "#13ec80")
            static let backgroundDark = UIColor(hex: "#102219")
            static let textSecondary = UIColor(hex: "#92c9ad")
        }
    }
    
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
}
