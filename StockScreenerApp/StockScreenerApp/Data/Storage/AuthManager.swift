//
//  AuthManager.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var currentUser: UserProfile?
    @Published var isLoggedIn: Bool = false
    
    private let userDefaultsKey = "currentUser"
    private let isLoggedInKey = "isLoggedIn"
    
    private init() {
        loadUser()
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) -> Bool {
        guard let savedUser = getSavedUser(), savedUser.email == email else {
            return false
        }
        
        currentUser = savedUser
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        return true
    }
    
    func register(name: String, email: String, password: String, profileImagePath: String? = nil) -> Bool {
        let newUser = UserProfile(name: name, email: email, profileImagePath: profileImagePath)
        
        do {
            let data = try JSONEncoder().encode(newUser)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
            
            currentUser = newUser
            isLoggedIn = true
            return true
        } catch {
            return false
        }
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
    }
    
    func updateProfile(name: String? = nil, profileImagePath: String? = nil) {
        guard var user = currentUser else { return }
        
        if let name = name {
            user.name = name
        }
        if let imagePath = profileImagePath {
            user.profileImagePath = imagePath
        }
        
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            currentUser = user
        } catch {
            return
        }
    }
    
    // MARK: - Private Methods
    
    private func loadUser() {
        isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        
        if isLoggedIn {
            currentUser = getSavedUser()
        }
    }
    
    private func getSavedUser() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        ProfileImageManager.shared.deleteProfileImage()
        currentUser = nil
        isLoggedIn = false
    }
}
