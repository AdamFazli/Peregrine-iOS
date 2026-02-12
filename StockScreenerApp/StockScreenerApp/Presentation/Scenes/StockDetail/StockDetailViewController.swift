//
//  StockDetailViewController.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import UIKit
import Combine

class StockDetailViewController: UIViewController {
    
    private var viewModel: StockDetailViewModel!
    private var cancellables = Set<AnyCancellable>()
    private let repository = WatchlistRepository.shared
    private var isInWatchlist = false
    private var currentStock: Stock?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.UI.Colors.primary
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let periodSelector: UISegmentedControl = {
        let periods = TimePeriod.allCases.map { $0.rawValue }
        let segmented = UISegmentedControl(items: periods)
        segmented.selectedSegmentIndex = 2
        segmented.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        segmented.selectedSegmentTintColor = Constants.UI.Colors.primary
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        return segmented
    }()
    
    private let chartView: SimpleLineChartView = {
        let view = SimpleLineChartView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.02)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsGridView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Constants.UI.Colors.primary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(symbol: String, stock: Stock? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = StockDetailViewModel(symbol: symbol, stock: stock)
        self.currentStock = stock
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWatchlistButton()
        bindViewModel()
        checkWatchlistStatus()
        
        Task {
            await viewModel.fetchData()
        }
    }
    
    private func setupUI() {
        title = viewModel.symbol
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(companyLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(periodSelector)
        contentView.addSubview(chartView)
        contentView.addSubview(statsGridView)
        view.addSubview(loadingIndicator)
        
        periodSelector.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            companyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            companyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 8),
            priceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            changeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            periodSelector.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 20),
            periodSelector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            periodSelector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            periodSelector.heightAnchor.constraint(equalToConstant: 32),
            
            chartView.topAnchor.constraint(equalTo: periodSelector.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            
            statsGridView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 24),
            statsGridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsGridView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupWatchlistButton() {
        let starButton = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(watchlistTapped)
        )
        starButton.tintColor = Constants.UI.Colors.primary
        navigationItem.rightBarButtonItem = starButton
    }
    
    private func bindViewModel() {
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
        
        viewModel.$stockDetail
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] detail in
                self?.updateUI(with: detail)
            }
            .store(in: &cancellables)
        
        viewModel.$stockHistory
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] history in
                self?.updateChart(with: history)
            }
            .store(in: &cancellables)
        
        viewModel.$companyOverview
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] _ in
                guard let self = self, let detail = self.viewModel.stockDetail else { return }
                self.setupStatsGrid(with: detail)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        viewModel.$retryCountdown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countdown in
                if countdown > 0 {
                    self?.updateErrorWithCountdown(countdown)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with detail: StockDetail) {
        companyLabel.text = detail.symbol
        priceLabel.text = detail.formattedPrice
        
        let changeText = "\(detail.formattedChange) (\(detail.formattedChangePercent))"
        changeLabel.text = changeText
        changeLabel.textColor = detail.isPositive ? Constants.UI.Colors.primary : UIColor(hex: "#ff4444")
        
        setupStatsGrid(with: detail)
    }
    
    private func updateChart(with history: StockHistory) {
        let selectedPeriod = TimePeriod.allCases[periodSelector.selectedSegmentIndex]
        var prices = history.pricesForPeriod(selectedPeriod)
        
        if prices.isEmpty {
            prices = history.prices
        }
        
        guard !prices.isEmpty else { return }
        
        chartView.layoutIfNeeded()
        
        let first = prices.first ?? 0
        let last = prices.last ?? 0
        let color = last > first ? Constants.UI.Colors.primary : UIColor(hex: "#ff4444")
        
        chartView.setData(prices, color: color, animated: true)
    }
    
    @objc private func periodChanged() {
        guard let history = viewModel.stockHistory else { return }
        updateChart(with: history)
    }
    
    @objc private func refreshData() {
        Task {
            await viewModel.fetchData()
            scrollView.refreshControl?.endRefreshing()
        }
    }
    
    private func setupStatsGrid(with detail: StockDetail) {
        statsGridView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Key Statistics"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        statsGridView.addArrangedSubview(titleLabel)
        
        let row1 = createStatsRow(
            stat1: ("HIGH", String(format: "$%.2f", detail.high)),
            stat2: ("LOW", String(format: "$%.2f", detail.low))
        )
        statsGridView.addArrangedSubview(row1)
        
        let row2 = createStatsRow(
            stat1: ("OPEN", String(format: "$%.2f", detail.open)),
            stat2: ("PREV CLOSE", String(format: "$%.2f", detail.previousClose))
        )
        statsGridView.addArrangedSubview(row2)
        
        let row3 = createStatsRow(
            stat1: ("VOLUME", formatVolume(detail.volume)),
            stat2: ("", "")
        )
        statsGridView.addArrangedSubview(row3)
        
        if let overview = viewModel.companyOverview {
            let row4 = createStatsRow(
                stat1: ("MARKET CAP", overview.formattedMarketCap),
                stat2: ("DIVIDEND", overview.formattedDividendYield)
            )
            statsGridView.addArrangedSubview(row4)
            
            let row5 = createStatsRow(
                stat1: ("52W HIGH", String(format: "$%@", overview.fiftyTwoWeekHigh)),
                stat2: ("52W LOW", String(format: "$%@", overview.fiftyTwoWeekLow))
            )
            statsGridView.addArrangedSubview(row5)
            
            if let pe = Double(overview.peRatio), pe > 0 {
                let row6 = createStatsRow(
                    stat1: ("P/E RATIO", String(format: "%.2f", pe)),
                    stat2: ("EPS", "$\(overview.eps)")
                )
                statsGridView.addArrangedSubview(row6)
            }
        }
        
        animateStatsGrid()
    }
    
    private func animateStatsGrid() {
        statsGridView.arrangedSubviews.enumerated().forEach { index, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 15)
            
            UIView.animate(
                withDuration: 0.4,
                delay: 0.1 + Double(index) * 0.08,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut]
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
    
    private func createStatsRow(stat1: (String, String), stat2: (String, String)) -> UIView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.distribution = .fillEqually
        
        func createStatCard(label: String, value: String) -> UIView {
            let container = UIView()
            container.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
            container.layer.cornerRadius = 12
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let labelView = UILabel()
            labelView.text = label
            labelView.font = .systemFont(ofSize: 12, weight: .medium)
            labelView.textColor = Constants.UI.Colors.textSecondary
            labelView.translatesAutoresizingMaskIntoConstraints = false
            
            let valueView = UILabel()
            valueView.text = value
            valueView.font = .systemFont(ofSize: 18, weight: .semibold)
            valueView.textColor = .white
            valueView.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(labelView)
            container.addSubview(valueView)
            
            NSLayoutConstraint.activate([
                labelView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                labelView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
                
                valueView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 4),
                valueView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                valueView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
                valueView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
                
                container.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
            ])
            
            return container
        }
        
        rowStack.addArrangedSubview(createStatCard(label: stat1.0, value: stat1.1))
        
        if !stat2.0.isEmpty {
            rowStack.addArrangedSubview(createStatCard(label: stat2.0, value: stat2.1))
        }
        
        return rowStack
    }
    
    private func formatVolume(_ volume: String) -> String {
        guard let volumeInt = Double(volume) else { return volume }
        
        if volumeInt >= 1_000_000_000 {
            return String(format: "%.2fB", volumeInt / 1_000_000_000)
        } else if volumeInt >= 1_000_000 {
            return String(format: "%.2fM", volumeInt / 1_000_000)
        } else if volumeInt >= 1_000 {
            return String(format: "%.2fK", volumeInt / 1_000)
        }
        return volume
    }
    
    @objc private func watchlistTapped() {
        guard let stock = currentStock else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        do {
            if isInWatchlist {
                try repository.remove(stock: stock)
                isInWatchlist = false
                updateWatchlistButton(filled: false)
            } else {
                try repository.save(stock: stock)
                isInWatchlist = true
                updateWatchlistButton(filled: true)
                animateStarButton()
            }
        } catch {
            showError("Failed to update watchlist")
        }
    }
    
    private func checkWatchlistStatus() {
        guard let stock = currentStock else { return }
        
        do {
            let allStocks = try repository.getAll()
            isInWatchlist = allStocks.contains { $0.symbol == stock.symbol }
            updateWatchlistButton(filled: isInWatchlist)
        } catch {
            isInWatchlist = false
            updateWatchlistButton(filled: false)
        }
    }
    
    private func updateWatchlistButton(filled: Bool) {
        let imageName = filled ? "star.fill" : "star"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
    }
    
    private func animateStarButton() {
        guard let button = navigationItem.rightBarButtonItem else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            button.customView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                button.customView?.transform = .identity
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateErrorWithCountdown(_ countdown: Int) {
        let message = "Rate limit exceeded. Please wait \(countdown) seconds."
        let alert = UIAlertController(title: "Rate Limit", message: message, preferredStyle: .alert)
        present(alert, animated: true)
    }
}
