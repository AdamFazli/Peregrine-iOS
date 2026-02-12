//
//  RegisterViewController.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import PhotosUI
import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var photoHintLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
        setupImageTap()
    }

    private func setupUI() {
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        
        titleLabel.textColor = .white
        subtitleLabel.textColor = Constants.UI.Colors.textSecondary
        
        profileImageContainer.backgroundColor = Constants.UI.Colors.cardDark
        profileImageContainer.layer.cornerRadius = 50
        profileImageContainer.layer.borderWidth = 2
        profileImageContainer.layer.borderColor = Constants.UI.Colors.primary.cgColor
        
        profileImageView.tintColor = Constants.UI.Colors.textSecondary
        profileImageView.layer.cornerRadius = 46
        profileImageView.clipsToBounds = true
        
        addPhotoButton.backgroundColor = Constants.UI.Colors.primary
        addPhotoButton.tintColor = .white
        addPhotoButton.layer.cornerRadius = 16
        
        photoHintLabel.textColor = Constants.UI.Colors.textSecondary
        
        nameTextField.backgroundColor = Constants.UI.Colors.cardDark
        nameTextField.textColor = .white
        nameTextField.layer.cornerRadius = 12
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Full Name",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        
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
        
        registerButton.backgroundColor = Constants.UI.Colors.primary
        registerButton.setTitleColor(.black, for: .normal)
        registerButton.layer.cornerRadius = 12
        
        let attributedString = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
        )
        attributedString.append(NSAttributedString(
            string: "Sign In",
            attributes: [.foregroundColor: Constants.UI.Colors.primary, .font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
        ))
        loginButton.setAttributedTitle(attributedString, for: .normal)
        
        errorLabel.isHidden = true
    }

    private func setupImageTap() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(addPhotoTapped))
        profileImageContainer.addGestureRecognizer(imageTap)
        profileImageContainer.isUserInteractionEnabled = true
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func addPhotoTapped() {
        let alertController = UIAlertController(title: "Profile Photo", message: "Choose a photo for your profile", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.presentCamera()
        })

        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentPhotoLibrary()
        })

        if selectedImage != nil {
            alertController.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
                self?.removePhoto()
            })
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showError("Camera not available")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func presentPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func removePhoto() {
        selectedImage = nil
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.contentMode = .scaleAspectFit
        photoHintLabel.text = "Tap to add photo (optional)"
    }

    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        addPhotoTapped()
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showError("Please enter your name")
            return
        }

        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Please enter your email")
            return
        }

        guard let password = passwordTextField.text, password.count >= 2 else {
            showError("Password must be at least 2 characters")
            return
        }

        var imagePath: String?
        if let image = selectedImage {
            imagePath = ProfileImageManager.shared.saveProfileImage(image)
        }

        if AuthManager.shared.register(name: name, email: email, password: password, profileImagePath: imagePath) {
            AuthManager.shared.logout()
            navigationController?.popViewController(animated: true)
        } else {
            showError("Registration failed. Please try again.")
        }
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
}

// MARK: - UIImagePickerControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let editedImage = info[.editedImage] as? UIImage {
            setProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            setProfileImage(originalImage)
        }
    }

    private func setProfileImage(_ image: UIImage) {
        selectedImage = image
        profileImageView.image = image
        profileImageView.contentMode = .scaleAspectFill
        photoHintLabel.text = "Tap to change photo"
    }
}

// MARK: - PHPickerViewControllerDelegate

extension RegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.setProfileImage(image)
                }
            }
        }
    }
}
