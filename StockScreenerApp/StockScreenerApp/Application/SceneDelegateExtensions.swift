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
        } else {
            setupMainFlow(window: window)
        }
        
        window.makeKeyAndVisible()
    }
    
    private func shouldShowOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.hasSeenOnboarding)
    }
    
    private func setupOnboardingFlow(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
        window.rootViewController = welcomeVC
    }
    
    private func setupMainFlow(window: UIWindow) {
        let mainTabBar = MainTabBarController()
        window.rootViewController = mainTabBar
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
}
