//
//  RegisterViewController.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import PhotosUI
import UIKit

class RegisterViewController: UIViewController {
    var onRegistrationComplete: (() -> Void)?

    private var selectedImage: UIImage?

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

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start your investment journey"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let profileImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.UI.Colors.cardDark
        view.layer.cornerRadius = 50
        view.layer.borderWidth = 2
        view.layer.borderColor = Constants.UI.Colors.primary.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = Constants.UI.Colors.textSecondary
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 46
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = Constants.UI.Colors.primary
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let photoHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to add photo (optional)"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = Constants.UI.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = Constants.UI.Colors.cardDark
        textField.textColor = .white
        textField.layer.cornerRadius = 12
        textField.autocapitalizationType = .words
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Full Name",
            attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
        )
        return textField
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = Constants.UI.Colors.cardDark
        textField.textColor = .white
        textField.layer.cornerRadius = 12
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
        )
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = Constants.UI.Colors.cardDark
        textField.textColor = .white
        textField.layer.cornerRadius = 12
        textField.isSecureTextEntry = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
        )
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = Constants.UI.Colors.primary
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        let attributedString = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: Constants.UI.Colors.textSecondary]
        )
        attributedString.append(NSAttributedString(
            string: "Sign In",
            attributes: [.foregroundColor: Constants.UI.Colors.primary, .font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
        ))
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = Constants.UI.Colors.backgroundDark
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImageView)
        contentView.addSubview(addPhotoButton)
        contentView.addSubview(photoHintLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(registerButton)
        contentView.addSubview(loginButton)

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

            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            profileImageContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            profileImageContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageContainer.widthAnchor.constraint(equalToConstant: 100),
            profileImageContainer.heightAnchor.constraint(equalToConstant: 100),

            profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: profileImageContainer.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 92),
            profileImageView.heightAnchor.constraint(equalToConstant: 92),

            addPhotoButton.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor, constant: 4),
            addPhotoButton.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 4),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 32),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 32),

            photoHintLabel.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 8),
            photoHintLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: photoHintLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nameTextField.heightAnchor.constraint(equalToConstant: 56),

            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),

            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            registerButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 56),

            loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 24),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

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

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
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

    @objc private func registerTapped() {
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

    @objc private func loginTapped() {
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
