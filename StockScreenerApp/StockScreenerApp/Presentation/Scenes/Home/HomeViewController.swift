import UIKit
import Combine

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = Constants.UI.Colors.primary
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let marketStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Market Overview"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let marketStatusStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topMoversLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Movers"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var topMoversCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = min(180, screenWidth * 0.45)
        layout.itemSize = CGSize(width: cellWidth, height: 100)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collection.delegate = self
        collection.dataSource = self
        collection.register(TopMoverCell.self, forCellWithReuseIdentifier: "TopMoverCell")
        return collection
    }()
    
    private let recentlyViewedLabel: UILabel = {
        let label = UILabel()
        label.text = "Recently Viewed"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
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
        collection.delegate = self
        collection.dataSource = self
        collection.register(RecentStockCell.self, forCellWithReuseIdentifier: "RecentStockCell")
        return collection
    }()
    
    private let emptyRecentLabel: UILabel = {
        let label = UILabel()
        label.text = "No recently viewed stocks.\nSearch for stocks to see them here."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = Constants.UI.Colors.primary
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()
    
    private var topMovers: [HomeViewModel.TopMover] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadRecentStocks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.refreshControl = refreshControl
        
        let leftStack = UIStackView()
        leftStack.axis = .vertical
        leftStack.alignment = .leading
        leftStack.spacing = 4
        leftStack.addArrangedSubview(greetingLabel)
        
        headerStack.addArrangedSubview(leftStack)
        headerStack.addArrangedSubview(avatarImageView)
        
        contentView.addSubview(headerStack)
        contentView.addSubview(marketStatusLabel)
        contentView.addSubview(marketStatusStack)
        contentView.addSubview(topMoversLabel)
        contentView.addSubview(topMoversCollection)
        contentView.addSubview(recentlyViewedLabel)
        contentView.addSubview(recentlyViewedCollection)
        contentView.addSubview(emptyRecentLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            marketStatusLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 32),
            marketStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            marketStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            marketStatusStack.topAnchor.constraint(equalTo: marketStatusLabel.bottomAnchor, constant: 12),
            marketStatusStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            marketStatusStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topMoversLabel.topAnchor.constraint(equalTo: marketStatusStack.bottomAnchor, constant: 32),
            topMoversLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topMoversLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            topMoversCollection.topAnchor.constraint(equalTo: topMoversLabel.bottomAnchor, constant: 12),
            topMoversCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topMoversCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topMoversCollection.heightAnchor.constraint(equalToConstant: 100),
            
            recentlyViewedLabel.topAnchor.constraint(equalTo: topMoversCollection.bottomAnchor, constant: 32),
            recentlyViewedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentlyViewedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            recentlyViewedCollection.topAnchor.constraint(equalTo: recentlyViewedLabel.bottomAnchor, constant: 12),
            recentlyViewedCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recentlyViewedCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recentlyViewedCollection.heightAnchor.constraint(equalToConstant: 90),
            recentlyViewedCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            emptyRecentLabel.topAnchor.constraint(equalTo: recentlyViewedLabel.bottomAnchor, constant: 20),
            emptyRecentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyRecentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyRecentLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        setupMarketStatus()
    }
    
    private func setupMarketStatus() {
        let indices = viewModel.getMarketIndices()
        
        for index in indices {
            let card = createMarketIndexCard(index: index)
            marketStatusStack.addArrangedSubview(card)
        }
    }
    
    private func createMarketIndexCard(index: HomeViewModel.MarketIndex) -> UIView {
        let container = UIView()
        container.backgroundColor = Constants.UI.Colors.cardDark
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let leftStack = UIStackView()
        leftStack.axis = .vertical
        leftStack.spacing = 4
        leftStack.alignment = .leading
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = index.name
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let symbolLabel = UILabel()
        symbolLabel.text = index.symbol
        symbolLabel.font = .systemFont(ofSize: 11, weight: .regular)
        symbolLabel.textColor = Constants.UI.Colors.textSecondary
        
        leftStack.addArrangedSubview(nameLabel)
        leftStack.addArrangedSubview(symbolLabel)
        
        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.spacing = 4
        rightStack.alignment = .trailing
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = index.price
        priceLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.textColor = .white
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.7
        priceLabel.textAlignment = .right
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let changeLabel = UILabel()
        changeLabel.text = "\(index.change) (\(index.changePercent))"
        changeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        changeLabel.textColor = index.isPositive ? Constants.UI.Colors.primary : .systemRed
        changeLabel.adjustsFontSizeToFitWidth = true
        changeLabel.minimumScaleFactor = 0.8
        changeLabel.textAlignment = .right
        
        rightStack.addArrangedSubview(priceLabel)
        rightStack.addArrangedSubview(changeLabel)
        
        container.addSubview(leftStack)
        container.addSubview(rightStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            leftStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            leftStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftStack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 12),
            leftStack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),
            
            rightStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            rightStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightStack.leadingAnchor.constraint(greaterThanOrEqualTo: leftStack.trailingAnchor, constant: 12),
            rightStack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 12),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),
            rightStack.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor, multiplier: 0.5)
        ])
        
        return container
    }
    
    private func bindViewModel() {
        viewModel.$greeting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] greeting in
                self?.greetingLabel.text = greeting
            }
            .store(in: &cancellables)
        
        viewModel.$recentStocks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stocks in
                self?.recentlyViewedCollection.isHidden = stocks.isEmpty
                self?.emptyRecentLabel.isHidden = !stocks.isEmpty
                self?.recentlyViewedCollection.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func loadData() {
        topMovers = viewModel.getTopMovers()
        topMoversCollection.reloadData()
        viewModel.loadRecentStocks()
    }
    
    @objc private func refreshData() {
        viewModel.loadRecentStocks()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topMoversCollection {
            return topMovers.count
        } else {
            return viewModel.recentStocks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topMoversCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopMoverCell", for: indexPath) as! TopMoverCell
            cell.configure(with: topMovers[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentStockCell", for: indexPath) as! RecentStockCell
            cell.configure(with: viewModel.recentStocks[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stock: Stock
        
        if collectionView == topMoversCollection {
            stock = topMovers[indexPath.item].stock
        } else {
            stock = viewModel.recentStocks[indexPath.item]
        }
        
        let detailVC = StockDetailViewController(symbol: stock.symbol, stock: stock)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

class TopMoverCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.UI.Colors.cardDark
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
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
        containerView.addSubview(priceLabel)
        containerView.addSubview(changeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            symbolLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            symbolLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            priceLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            changeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            changeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with mover: HomeViewModel.TopMover) {
        symbolLabel.text = mover.stock.symbol
        priceLabel.text = mover.price
        changeLabel.text = mover.changePercent
        changeLabel.textColor = mover.isPositive ? Constants.UI.Colors.primary : .systemRed
        
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
    }
}
