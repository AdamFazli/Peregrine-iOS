//
//  SettingsViewController.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import UIKit
import Combine

class SettingsViewController: UIViewController {
    
    private let viewModel = SettingsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = Constants.UI.Colors.backgroundDark
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupFooter()
    }
    
    private func setupFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        iconImageView.tintColor = Constants.UI.Colors.primary
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let versionLabel = UILabel()
        versionLabel.text = "StockScreener\nv\(viewModel.appVersion) (Build \(viewModel.buildNumber))"
        versionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        versionLabel.textColor = Constants.UI.Colors.textSecondary
        versionLabel.textAlignment = .center
        versionLabel.numberOfLines = 0
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(iconImageView)
        footerView.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            versionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            versionLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20)
        ])
        
        tableView.tableFooterView = footerView
    }
    
    private func bindViewModel() {
        viewModel.$selectedLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func showLanguageSelector() {
        let alert = UIAlertController(
            title: "Language",
            message: "Select your preferred language",
            preferredStyle: .actionSheet
        )
        
        for language in viewModel.availableLanguages {
            let action = UIAlertAction(title: language, style: .default) { [weak self] _ in
                self?.viewModel.selectedLanguage = language
            }
            if language == viewModel.selectedLanguage {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showClearCacheAlert() {
        let cacheSize = viewModel.getCacheSize()
        
        let alert = UIAlertController(
            title: "Clear Local Cache",
            message: "This will remove all watchlist stocks and recently viewed data (\(cacheSize)). This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.clearCache()
        })
        
        present(alert, animated: true)
    }
    
    private func clearCache() {
        do {
            try viewModel.clearCache()
            
            let successAlert = UIAlertController(
                title: "Cache Cleared",
                message: "All local data has been removed.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(successAlert, animated: true)
            
            tableView.reloadData()
        } catch {
            let errorAlert = UIAlertController(
                title: "Error",
                message: "Failed to clear cache: \(error.localizedDescription)",
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }
    }
    
    private func showAboutApp() {
        let alert = UIAlertController(
            title: "About StockScreener",
            message: "A modern stock screening app with real-time market data, watchlists, and comprehensive stock analysis.\n\nBuilt with Swift & UIKit",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showPrivacyPolicy() {
        let alert = UIAlertController(
            title: "Privacy Policy",
            message: "This app stores your watchlist and recently viewed stocks locally on your device. No personal data is collected or shared with third parties.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showRateUs() {
        let alert = UIAlertController(
            title: "Rate Us",
            message: "Thank you for using StockScreener! Your feedback helps us improve.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return 3
        case 3: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell")
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = Constants.UI.Colors.textSecondary
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "Language"
            cell.imageView?.image = UIImage(systemName: "globe")
            cell.imageView?.tintColor = UIColor(hex: "#4A9EFF")
            cell.detailTextLabel?.text = viewModel.selectedLanguage
            cell.accessoryType = .disclosureIndicator
            
        case (0, 1):
            cell.textLabel?.text = "Notifications"
            cell.imageView?.image = UIImage(systemName: "bell.fill")
            cell.imageView?.tintColor = UIColor(hex: "#FF6B6B")
            cell.accessoryType = .disclosureIndicator
            
        case (1, 0):
            cell.textLabel?.text = "Clear Local Cache"
            cell.imageView?.image = UIImage(systemName: "trash.fill")
            cell.imageView?.tintColor = UIColor(hex: "#FFD93D")
            cell.detailTextLabel?.text = viewModel.getCacheSize()
            cell.accessoryType = .disclosureIndicator
            
        case (2, 0):
            cell.textLabel?.text = "About the App"
            cell.imageView?.image = UIImage(systemName: "info.circle.fill")
            cell.imageView?.tintColor = Constants.UI.Colors.primary
            cell.accessoryType = .disclosureIndicator
            
        case (2, 1):
            cell.textLabel?.text = "Privacy Policy"
            cell.imageView?.image = UIImage(systemName: "lock.shield.fill")
            cell.imageView?.tintColor = UIColor(hex: "#A78BFA")
            cell.accessoryType = .disclosureIndicator
            
        case (2, 2):
            cell.textLabel?.text = "Rate Us"
            cell.imageView?.image = UIImage(systemName: "star.fill")
            cell.imageView?.tintColor = Constants.UI.Colors.primary
            cell.accessoryType = .disclosureIndicator
            
        case (3, 0):
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textColor = .systemRed
            cell.imageView?.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            cell.imageView?.tintColor = .systemRed
            cell.accessoryType = .none
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "PREFERENCES"
        case 1: return "DATA MANAGEMENT"
        case 2: return "INFORMATION"
        case 3: return "ACCOUNT"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Constants.UI.Colors.textSecondary
        header.textLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showLanguageSelector()
            
        case (0, 1):
            openAppSettings()
            
        case (1, 0):
            showClearCacheAlert()
            
        case (2, 0):
            showAboutApp()
            
        case (2, 1):
            showPrivacyPolicy()
            
        case (2, 2):
            showRateUs()
            
        case (3, 0):
            showLogoutConfirmation()
            
        default:
            break
        }
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        AuthManager.shared.logout()
        
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.switchToLoginFlow()
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3 {
            return "StockScreener v\(viewModel.appVersion) (Build \(viewModel.buildNumber))"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.textColor = Constants.UI.Colors.textSecondary
        footer.textLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        footer.textLabel?.textAlignment = .center
    }
}
