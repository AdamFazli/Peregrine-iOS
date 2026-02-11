//
//  MainTabBarController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let topBorderLayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 0.5)
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = Constants.UI.Colors.backgroundDark
        tabBar.barTintColor = Constants.UI.Colors.backgroundDark
        tabBar.tintColor = Constants.UI.Colors.primary
        tabBar.unselectedItemTintColor = UIColor(white: 0.6, alpha: 1.0)
        tabBar.isTranslucent = false
        
        topBorderLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        tabBar.layer.addSublayer(topBorderLayer)
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Constants.UI.Colors.backgroundDark
            
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.3)
            appearance.shadowImage = UIImage()
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.6, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(white: 0.6, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 11, weight: .medium)
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = Constants.UI.Colors.primary
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: Constants.UI.Colors.primary,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        let homeVC = HomeViewController()
        let homeNav = createNavigationController(
            rootViewController: homeVC,
            title: "Home",
            image: UIImage(systemName: "house")
        )
        
        let searchVC = SearchViewController()
        let searchNav = createNavigationController(
            rootViewController: searchVC,
            title: "Search",
            image: UIImage(systemName: "magnifyingglass")
        )
        
        let watchlistVC = WatchlistViewController()
        let watchlistNav = createNavigationController(
            rootViewController: watchlistVC,
            title: "Watchlist",
            image: UIImage(systemName: "chart.pie")
        )
        
        let settingsVC = SettingsViewController()
        let settingsNav = createNavigationController(
            rootViewController: settingsVC,
            title: "Settings",
            image: UIImage(systemName: "gearshape")
        )
        
        viewControllers = [homeNav, searchNav, watchlistNav, settingsNav]
    }
    
    private func createNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage?
    ) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Constants.UI.Colors.backgroundDark
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.compactAppearance = appearance
        }
        
        navController.navigationBar.tintColor = Constants.UI.Colors.primary
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
}
