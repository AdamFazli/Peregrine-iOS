//
//  LoginViewController.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        logoImageView.tintColor = Constants.UI.Colors.primary
        titleLabel.textColor = .white
        subtitleLabel.textColor = Constants.UI.Colors.textSecondary
        
        emailTextField.backgroundColor = Constants.UI.Colors.cardDark
        emailTextField.textColor = .white
        emailTextField.layer.cornerRadius = 12
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        
        passwordTextField.backgroundColor = Constants.UI.Colors.cardDark
        passwordTextField.textColor = .white
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        
        loginButton.backgroundColor = Constants.UI.Colors.primary
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.layer.cornerRadius = 12
        
        let attributedString = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
        )
        attributedString.append(NSAttributedString(
            string: "Register",
            attributes: [.foregroundColor: Constants.UI.Colors.primary, .font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
        ))
        registerButton.setAttributedTitle(attributedString, for: .normal)
        
        errorLabel.isHidden = true
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter email and password")
            return
        }
        
        if AuthManager.shared.login(email: email, password: password) {
            navigateToMain()
        } else {
            showError("Invalid credentials. Please register first.")
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegister", sender: nil)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3) {
                self.errorLabel.alpha = 0
            } completion: { _ in
                self.errorLabel.isHidden = true
            }
        }
    }
    
    private func navigateToMain() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.switchToMainFlow()
    }
}
