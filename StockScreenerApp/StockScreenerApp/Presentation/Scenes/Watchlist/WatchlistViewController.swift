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
    private let networkManager = NetworkManager.shared
    private var stockPrices: [String: (price: Double, change: Double)] = [:]
    private var isLoadingPrices = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
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
    
    private func loadWatchlist() {
        do {
            stocks = try repository.getAll()
            updateEmptyState()
            tableView.reloadData()
            
            if !stocks.isEmpty {
                fetchRealPrices()
            }
        } catch {
            showError("Failed to load watchlist: \(error.localizedDescription)")
        }
    }
    
    private func fetchRealPrices() {
        guard !isLoadingPrices else { return }
        isLoadingPrices = true
        
        Task {
            for (index, stock) in stocks.enumerated() {
                do {
                    let quoteResponse: QuoteResponse = try await networkManager.fetch(
                        endpoint: StockEndpoint.quote(symbol: stock.symbol)
                    )
                    
                    let detail = quoteResponse.globalQuote
                    let changePercent = Double(detail.changePercent.replacingOccurrences(of: "%", with: "")) ?? 0.0
                    
                    await MainActor.run {
                        self.stockPrices[stock.symbol] = (detail.price, changePercent)
                        
                        if let visibleIndexPath = self.tableView.indexPathsForVisibleRows?.first(where: { $0.row == index }) {
                            self.tableView.reloadRows(at: [visibleIndexPath], with: .none)
                        }
                    }
                    
                    if index < stocks.count - 1 {
                        try await Task.sleep(nanoseconds: 200_000_000)
                    }
                    
                } catch let error as NetworkError {
                    if case .rateLimitExceeded = error {
                        await MainActor.run {
                            self.subtitleLabel.text = "Rate limit reached. Pull to refresh later."
                        }
                        break
                    }
                } catch {
                    continue
                }
            }
            
            await MainActor.run {
                self.isLoadingPrices = false
                self.tableView.refreshControl?.endRefreshing()
            }
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
        stockPrices.removeAll()
        loadWatchlist()
    }
}
