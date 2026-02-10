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
        let placeholderVC = UIViewController()
        placeholderVC.view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        let label = UILabel()
        label.text = "Main App Coming Soon"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderVC.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: placeholderVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: placeholderVC.view.centerYAnchor)
        ])
        
        window.rootViewController = placeholderVC
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
