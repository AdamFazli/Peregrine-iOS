//
//  MainTabBarController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = Constants.UI.Colors.backgroundDark
        tabBar.barTintColor = Constants.UI.Colors.backgroundDark
        tabBar.tintColor = Constants.UI.Colors.primary
        tabBar.unselectedItemTintColor = UIColor(white: 0.5, alpha: 1.0)
        tabBar.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Constants.UI.Colors.backgroundDark
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.5, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(white: 0.5, alpha: 1.0)
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = Constants.UI.Colors.primary
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: Constants.UI.Colors.primary
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
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
            image: UIImage(systemName: "star")
        )
        
        viewControllers = [searchNav, watchlistNav]
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
