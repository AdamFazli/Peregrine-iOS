//
//  WatchlistViewController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class WatchlistViewController: UIViewController {
    
    private var stocks: [Stock] = []
    private let repository = WatchlistRepository.shared
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Constants.UI.Colors.backgroundDark
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No stocks in watchlist\nSearch and add stocks to track"
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWatchlist()
    }
    
    private func setupUI() {
        title = "Watchlist"
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadWatchlist() {
        do {
            stocks = try repository.getAll()
            updateEmptyState()
            tableView.reloadData()
        } catch {
            showError("Failed to load watchlist: \(error.localizedDescription)")
        }
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !stocks.isEmpty
        tableView.isHidden = stocks.isEmpty
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension WatchlistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.reuseIdentifier, for: indexPath) as? StockCell else {
            return UITableViewCell()
        }
        
        let stock = stocks[indexPath.row]
        cell.configure(with: stock)
        return cell
    }
}

extension WatchlistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = stocks[indexPath.row]
        let detailVC = StockDetailViewController(symbol: stock.symbol, stock: stock)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let stock = self.stocks[indexPath.row]
            
            do {
                try self.repository.remove(stock: stock)
                self.stocks.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.updateEmptyState()
                completion(true)
            } catch {
                self.showError("Failed to remove stock")
                completion(false)
            }
        }
        
        deleteAction.backgroundColor = UIColor(hex: "#ff4444")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
