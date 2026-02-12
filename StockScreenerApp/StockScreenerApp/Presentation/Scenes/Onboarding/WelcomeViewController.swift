//
//  WelcomeViewController.swift
//  StockScreenerApp
//
//  Created on 2/10/26.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        appLogoImageView.layer.cornerRadius = 16
        appLogoImageView.clipsToBounds = true
        appLogoImageView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(string: "Smart Stock\n", attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 36, weight: .bold)
        ]))
        title.append(NSAttributedString(string: "Screening", attributes: [
            .foregroundColor: Constants.UI.Colors.primary,
            .font: UIFont.systemFont(ofSize: 36, weight: .bold)
        ]))
        titleLabel.attributedText = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        subtitleLabel.text = "Track real-time market data and\ndiscover high-potential stocks\ninstantly."
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = Constants.UI.Colors.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        getStartedButton.backgroundColor = Constants.UI.Colors.primary
        getStartedButton.setTitleColor(Constants.UI.Colors.backgroundDark, for: .normal)
        getStartedButton.layer.cornerRadius = 12
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.switchToAuthFlow()
    }
}
