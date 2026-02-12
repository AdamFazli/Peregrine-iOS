//
//  SceneDelegateExtensions.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

extension SceneDelegate {
    
    func setupWindow(scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        self.window = window
        
        if shouldShowOnboarding() {
            setupOnboardingFlow(window: window)
        } else if !isLoggedIn() {
            setupAuthFlow(window: window)
        } else {
            setupMainFlow(window: window)
        }
        
        window.makeKeyAndVisible()
    }
    
    private func shouldShowOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.hasSeenOnboarding)
    }
    
    private func isLoggedIn() -> Bool {
        return AuthManager.shared.isLoggedIn
    }
    
    private func setupOnboardingFlow(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
        window.rootViewController = welcomeVC
    }
    
    private func setupAuthFlow(window: UIWindow) {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navController
    }
    
    private func setupMainFlow(window: UIWindow) {
        let mainTabBar = MainTabBarController()
        window.rootViewController = mainTabBar
    }
    
    func switchToAuthFlow() {
        guard let window = window else { return }
        
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasSeenOnboarding)
        
        if isLoggedIn() {
            setupMainFlow(window: window)
        } else {
            setupAuthFlow(window: window)
        }
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
    
    func switchToMainFlow() {
        guard let window = window else { return }
        
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasSeenOnboarding)
        setupMainFlow(window: window)
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
    
    func switchToLoginFlow() {
        guard let window = window else { return }
        
        setupAuthFlow(window: window)
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
