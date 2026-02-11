//
//  SearchViewController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    
    private let viewModel = SearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search ticker, company, or ETF..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var dashboardView: DashboardView = {
        let dashboard = DashboardView()
        dashboard.translatesAutoresizingMaskIntoConstraints = false
        dashboard.delegate = self
        return dashboard
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Constants.UI.Colors.backgroundDark
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.UI.Colors.primary
        refreshControl.addTarget(self, action: #selector(refreshSearch), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.textColor = Constants.UI.Colors.textSecondary
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Constants.UI.Colors.primary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchBar()
        bindViewModel()
        updateViewMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dashboardView.loadRecentStocks()
    }
    
    private func setupUI() {
        title = "Search"
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        view.addSubview(searchBar)
        view.addSubview(dashboardView)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            dashboardView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            dashboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dashboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dashboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        styleSearchBar()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.reuseIdentifier)
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func styleSearchBar() {
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search ticker, company, or ETF...",
                attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
            )
            textField.leftView?.tintColor = Constants.UI.Colors.textSecondary
        }
    }
    
    private func bindViewModel() {
        viewModel.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.updateUI(results: results)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(results: [Stock]) {
        updateViewMode()
        
        if results.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
            emptyStateLabel.isHidden = false
            emptyStateLabel.text = "No results found for '\(viewModel.searchText)'"
        } else {
            emptyStateLabel.isHidden = true
        }
    }
    
    private func updateViewMode() {
        let isSearching = !viewModel.searchText.isEmpty
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dashboardView.alpha = isSearching ? 0 : 1
            self.tableView.alpha = isSearching ? 1 : 0
        }) { _ in
            self.dashboardView.isHidden = isSearching
            self.tableView.isHidden = !isSearching
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StockCell.reuseIdentifier,
            for: indexPath
        ) as? StockCell else {
            return UITableViewCell()
        }
        
        let stock = viewModel.results[indexPath.row]
        cell.configure(with: stock)
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: 0.4,
            delay: Double(indexPath.row) * 0.05,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = viewModel.results[indexPath.row]
        let detailVC = StockDetailViewController(symbol: stock.symbol, stock: stock)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func refreshSearch() {
        if !viewModel.searchText.isEmpty {
            viewModel.searchText = viewModel.searchText
        }
        tableView.refreshControl?.endRefreshing()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        updateViewMode()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.clearSearch()
        searchBar.resignFirstResponder()
        updateViewMode()
    }
}

// MARK: - DashboardViewDelegate

extension SearchViewController: DashboardViewDelegate {
    func dashboardView(_ view: DashboardView, didSelectStock stock: Stock) {
        let detailVC = StockDetailViewController(symbol: stock.symbol, stock: stock)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
