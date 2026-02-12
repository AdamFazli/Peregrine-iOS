//
//  WatchlistStockCell.swift
//  StockScreenerApp
//
//  Created on 2/13/26.
//

import UIKit

class WatchlistStockCell: UITableViewCell {
    static let reuseIdentifier = "WatchlistStockCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.UI.Colors.cardDark
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        iconView.addSubview(iconLabel)
        containerView.addSubview(iconView)
        containerView.addSubview(symbolLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(changeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            symbolLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            symbolLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
            
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            priceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            changeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            changeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with stock: Stock, price: Double, changePercent: Double) {
        symbolLabel.text = stock.symbol
        nameLabel.text = stock.name
        
        let color = colorForSymbol(stock.symbol)
        iconView.backgroundColor = color.withAlphaComponent(0.2)
        iconLabel.text = String(stock.symbol.prefix(1))
        iconLabel.textColor = color
        
        priceLabel.text = "$\(String(format: "%.2f", price))"
        
        let changeColor = changePercent >= 0 ? UIColor(hex: "#4CAF50") : UIColor(hex: "#FF5252")
        let changeSign = changePercent >= 0 ? "+" : ""
        changeLabel.text = "\(changeSign)\(String(format: "%.2f", changePercent))%"
        changeLabel.textColor = changeColor
    }
    
    private func colorForSymbol(_ symbol: String) -> UIColor {
        let colors: [UIColor] = [
            Constants.UI.Colors.primary,
            UIColor(hex: "#4A9EFF"),
            UIColor(hex: "#FF6B6B"),
            UIColor(hex: "#FFD93D"),
            UIColor(hex: "#6BCF7F"),
            UIColor(hex: "#A78BFA"),
            UIColor(hex: "#FF9CEE"),
            UIColor(hex: "#54D9FF")
        ]
        
        let hash = symbol.hashValue
        return colors[abs(hash) % colors.count]
    }
}
