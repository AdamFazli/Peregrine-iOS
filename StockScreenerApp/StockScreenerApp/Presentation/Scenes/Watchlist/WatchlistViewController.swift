//
//  WatchlistViewController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class WatchlistViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Watchlist"
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        let label = UILabel()
        label.text = "Watchlist Screen"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
