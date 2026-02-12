//
//  DashboardView.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import UIKit

protocol DashboardViewDelegate: AnyObject {
    func dashboardView(_ view: DashboardView, didSelectStock stock: Stock)
}

class DashboardView: UIView {
    
    weak var delegate: DashboardViewDelegate?
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let marketStatusContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let marketStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Market Status"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let marketIndicesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let recentlyViewedLabel: UILabel = {
        let label = UILabel()
        label.text = "Recently Viewed"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var recentlyViewedCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = min(160, screenWidth * 0.4)
        layout.itemSize = CGSize(width: cellWidth, height: 80)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return collection
    }()
    
    private let emptyRecentLabel: UILabel = {
        let label = UILabel()
        label.text = "No recently viewed stocks"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var recentStocks: [Stock] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupMarketStatus()
        loadRecentStocks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = Constants.UI.Colors.backgroundDark
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(marketStatusContainer)
        marketStatusContainer.addSubview(marketStatusLabel)
        marketStatusContainer.addSubview(marketIndicesStack)
        
        contentView.addSubview(recentlyViewedLabel)
        contentView.addSubview(recentlyViewedCollection)
        contentView.addSubview(emptyRecentLabel)
        
        recentlyViewedCollection.delegate = self
        recentlyViewedCollection.dataSource = self
        recentlyViewedCollection.register(RecentStockCell.self, forCellWithReuseIdentifier: RecentStockCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            marketStatusContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            marketStatusContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            marketStatusContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            marketStatusContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
            
            marketStatusLabel.topAnchor.constraint(equalTo: marketStatusContainer.topAnchor, constant: 16),
            marketStatusLabel.leadingAnchor.constraint(equalTo: marketStatusContainer.leadingAnchor, constant: 16),
            marketStatusLabel.trailingAnchor.constraint(equalTo: marketStatusContainer.trailingAnchor, constant: -16),
            
            marketIndicesStack.topAnchor.constraint(equalTo: marketStatusLabel.bottomAnchor, constant: 16),
            marketIndicesStack.leadingAnchor.constraint(equalTo: marketStatusContainer.leadingAnchor, constant: 16),
            marketIndicesStack.trailingAnchor.constraint(equalTo: marketStatusContainer.trailingAnchor, constant: -16),
            marketIndicesStack.bottomAnchor.constraint(equalTo: marketStatusContainer.bottomAnchor, constant: -16),
            
            recentlyViewedLabel.topAnchor.constraint(equalTo: marketStatusContainer.bottomAnchor, constant: 32),
            recentlyViewedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentlyViewedLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            recentlyViewedCollection.topAnchor.constraint(equalTo: recentlyViewedLabel.bottomAnchor, constant: 12),
            recentlyViewedCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recentlyViewedCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recentlyViewedCollection.heightAnchor.constraint(equalToConstant: 90),
            recentlyViewedCollection.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            
            emptyRecentLabel.topAnchor.constraint(equalTo: recentlyViewedLabel.bottomAnchor, constant: 20),
            emptyRecentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyRecentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyRecentLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupMarketStatus() {
        let indices = [
            ("S&P 500", "4,783.45", "+0.85%", true),
            ("NASDAQ", "15,310.97", "+1.24%", true),
            ("DOW", "37,863.80", "-0.12%", false)
        ]
        
        for (name, value, change, isPositive) in indices {
            let indexView = createMarketIndexView(name: name, value: value, change: change, isPositive: isPositive)
            marketIndicesStack.addArrangedSubview(indexView)
        }
    }
    
    private func createMarketIndexView(name: String, value: String, change: String, isPositive: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = Constants.UI.Colors.textSecondary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let changeLabel = UILabel()
        changeLabel.text = change
        changeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        changeLabel.textColor = isPositive ? Constants.UI.Colors.primary : UIColor(hex: "#ff4444")
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(nameLabel)
        container.addSubview(valueLabel)
        container.addSubview(changeLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            changeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            changeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: changeLabel.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        return container
    }
    
    func loadRecentStocks() {
        do {
            recentStocks = try RecentlyViewedManager.shared.getAll()
            
            if recentStocks.isEmpty {
                recentlyViewedCollection.isHidden = true
                emptyRecentLabel.isHidden = false
            } else {
                recentlyViewedCollection.isHidden = false
                emptyRecentLabel.isHidden = true
                recentlyViewedCollection.reloadData()
            }
        } catch {
            recentStocks = []
            recentlyViewedCollection.isHidden = true
            emptyRecentLabel.isHidden = false
        }
    }
}

extension DashboardView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentStocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentStockCell.reuseIdentifier, for: indexPath) as? RecentStockCell else {
            return UICollectionViewCell()
        }
        
        let stock = recentStocks[indexPath.item]
        cell.configure(with: stock)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stock = recentStocks[indexPath.item]
        delegate?.dashboardView(self, didSelectStock: stock)
    }
}

class RecentStockCell: UICollectionViewCell {
    static let reuseIdentifier = "RecentStockCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(symbolLabel)
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            symbolLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            symbolLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            symbolLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with stock: Stock) {
        symbolLabel.text = stock.symbol
        nameLabel.text = stock.name
    }
}
