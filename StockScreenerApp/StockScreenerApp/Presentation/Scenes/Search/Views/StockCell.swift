//
//  StockCell.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class StockCell: UITableViewCell {
    static let reuseIdentifier = "StockCell"
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Constants.UI.Colors.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Constants.UI.Colors.primary
        label.textAlignment = .center
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
        backgroundColor = Constants.UI.Colors.backgroundDark
        selectionStyle = .none
        
        iconView.addSubview(iconLabel)
        contentView.addSubview(iconView)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            symbolLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: typeLabel.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            typeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with stock: Stock) {
        symbolLabel.text = stock.symbol
        nameLabel.text = stock.name
        typeLabel.text = stock.displayType
        iconLabel.text = String(stock.symbol.prefix(2))
    }
}
