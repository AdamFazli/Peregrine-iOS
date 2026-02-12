//
//  WatchlistViewController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class WatchlistViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyIconLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    private var stocks: [Stock] = []
    private let repository = WatchlistRepository.shared
    private var stockPrices: [String: (price: Double, change: Double)] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        generateMockPrices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadWatchlist()
    }
    
    private func setupUI() {
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.UI.Colors.primary
        refreshControl.addTarget(self, action: #selector(refreshWatchlist), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupTableView() {
        tableView.register(WatchlistStockCell.self, forCellReuseIdentifier: WatchlistStockCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func generateMockPrices() {
        let mockData: [String: (Double, Double)] = [
            "AAPL": (178.35, 1.25),
            "GOOGL": (135.20, 2.10),
            "MSFT": (329.80, -0.32),
            "AMZN": (142.50, 0.95),
            "TSLA": (245.60, 3.48),
            "META": (312.45, 1.85),
            "NVDA": (485.10, 5.12),
            "NFLX": (432.11, -0.85)
        ]
        
        for stock in stocks {
            if let data = mockData[stock.symbol] {
                stockPrices[stock.symbol] = data
            } else {
                let randomPrice = Double.random(in: 50...500)
                let randomChange = Double.random(in: -5...5)
                stockPrices[stock.symbol] = (randomPrice, randomChange)
            }
        }
    }
    
    private func loadWatchlist() {
        do {
            stocks = try repository.getAll()
            generateMockPrices()
            updateEmptyState()
            tableView.reloadData()
        } catch {
            showError("Failed to load watchlist: \(error.localizedDescription)")
        }
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !stocks.isEmpty
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistStockCell.reuseIdentifier, for: indexPath) as? WatchlistStockCell else {
            return UITableViewCell()
        }
        
        let stock = stocks[indexPath.row]
        let priceData = stockPrices[stock.symbol] ?? (0.0, 0.0)
        cell.configure(with: stock, price: priceData.price, changePercent: priceData.change)
        
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
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                }) { _ in
                    self.updateEmptyState()
                }
                
                completion(true)
            } catch {
                self.showError("Failed to remove stock")
                completion(false)
            }
        }
        
        deleteAction.backgroundColor = UIColor(hex: "#ff4444")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @objc private func refreshWatchlist() {
        loadWatchlist()
        tableView.refreshControl?.endRefreshing()
    }
}
