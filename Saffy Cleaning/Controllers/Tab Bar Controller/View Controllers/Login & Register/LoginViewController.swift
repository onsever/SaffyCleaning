//
//  ViewController.swift
//  Saffy Cleaning
//
//  Created by Onurcan Sever on 2022-03-09.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import JGProgressHUD


class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    private let firstView = UIView()
    private let secondView = UIView()
    private let thirdView = UIView()
    
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sc_brand_logo")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var logoTitleLabel = SCTitleLabel(fontSize: 32, textColor: .brandDark)
    private lazy var logoSubTitleLabel = SCSubTitleLabel(text: "Keep your place clean\nSafe and effective", isRequired: false, textColor: .brandDark)
    private lazy var usernameTextField = SCTextField(placeholder: "Email")
    private lazy var passwordTextField = SCTextField(placeholder: "Password")
    private var textFieldStackView: SCStackView!
    private lazy var forgetPasswordLabel = SCCompletionLabel(title: "Forget Password", titleColor: .brandDark, fontSize: 13)
    private let loginButton = SCMainButton(title: "Log in", backgroundColor: .brandYellow, titleColor: .brandDark, cornerRadius: 10, fontSize: nil)
    private let signUpButton = SCMainButton(title: "Sign Up", backgroundColor: .white, titleColor: .brandGem, borderColor: .brandGem, cornerRadius: 10, fontSize: nil)
    private var buttonStackView: SCStackView!
    private let googleSignInView = SCSignInView(image: UIImage(named: "sc_google_logo"), title: "Continue with Google")
    private let facebookSignInView = SCSignInView(image: UIImage(named: "sc_facebook_logo"), title: "Continue with Facebook")
    private var signInStackView: SCStackView!

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureFirstView()
        configureSecondView()
        configureThirdView()
        configureLogoImageView()
        configureLogoTitleLabel()
        configureLogoSubTitleLabel()
        configureTextFieldStackView()
        configureForgetPasswordLabel()
        configureButtonStackView()
        configureSignInStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Selectors
    @objc private func loginButtonDidTapped(_ button: UIButton) {
        button.animateWithSpring()
        spinner.show(in: view)
        guard let username = usernameTextField.text, let password = passwordTextField.text else {return }
        FirebaseAuthService.service.signIn(email: username, pass: password) {[weak self] (success) in
            if (success) {
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(MainTabBarController())
                }
            } else {
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                    self?.presentAlert(title: "Login", message: "Password is not currect", positiveAction: { action in
                    }, negativeAction: nil)
                }

            }
        }

    }
    
    @objc private func signUpButtonDidTapped(_ button: UIButton) {
        button.animateWithSpring()
        
        let viewController = SignUpViewController()
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func continueWithGoogleDidTapped(_ gesture: UITapGestureRecognizer) {
        googleSignInView.animateWithSpring()
        spinner.show(in: view)
        GIDSignIn.sharedInstance.signIn(with: FirebaseAuthService.googleSignConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let authentication = user?.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken ?? "", accessToken: authentication.accessToken)
            FirebaseAuthService.service.loginWithThirdParties(credential: credential, completionBlock: {
                [weak self] (success) in
                if (success) {
                    self?.spinner.dismiss()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(MainTabBarController())
                    
                } else {
                    self?.presentAlert(title: "Login with Google", message: "Login Failed", positiveAction: { action in }, negativeAction: nil)
                }
                
            })
            
            
        }
    }
    
    @objc private func continueWithFacebookDidTapped(_ gesture: UITapGestureRecognizer) {
        facebookSignInView.animateWithSpring()
        spinner.show(in: view)
        LoginManager.init().logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { (loginResult) in
          switch loginResult {
          case .success(_, _, _):
              let facebookToken = AccessToken.current!.tokenString
              let credential = FacebookAuthProvider.credential(withAccessToken: facebookToken)
              FirebaseAuthService.service.loginWithThirdParties(credential: credential, completionBlock: {
                  [weak self] (success) in
                  if (success) {
                      DispatchQueue.main.async {
                          self?.spinner.dismiss()
                          (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(MainTabBarController())
                      }
                  } else {
                      self?.presentAlert(title: "Login with FB", message: "Login Failed", positiveAction: { action in }, negativeAction: nil)
                  }
              })
          case .cancelled:
              print("Login: cancelled.")
          case .failed(let error):
            print("Login with error: \(error.localizedDescription)")
          }
        }
    }
    
    
    
    @objc private func forgetPasswordDidTapped(_ gesture: UITapGestureRecognizer) {
        print("Forget password label tapped on.")
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text!.count == 0 {
            textField.rightView = nil
            textField.layer.borderColor = UIColor.brandGem.cgColor
            textField.tintColor = .brandGem
            return
        }
        
        textField.rightViewMode = .always
        
        if textField.text!.count > 5 {
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
            let image = UIImage(systemName: "checkmark")
            imageView.image = image
            let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageContainerView.addSubview(imageView)
            textField.rightView = imageContainerView
            
            textField.layer.borderColor = UIColor.brandGem.cgColor
            
            textField.tintColor = .brandGem
        }
        else {
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
            let image = UIImage(systemName: "xmark")
            imageView.image = image
            let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageContainerView.addSubview(imageView)
            textField.rightView = imageContainerView
            
            textField.layer.borderColor = UIColor.brandError.cgColor
            
            textField.tintColor = .brandError
        }
    }


}

// MARK: - Firebase Methods
extension LoginViewController {
    
}

// MARK: - UIConfiguration Methods
extension LoginViewController {
    
    private func configureViewController() {
        view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func configureFirstView() {
        view.addSubview(firstView)
        firstView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            firstView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            firstView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            firstView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
    
    private func configureSecondView() {
        view.addSubview(secondView)
        secondView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            secondView.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: 0),
            secondView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            secondView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            secondView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
    
    private func configureThirdView() {
        view.addSubview(thirdView)
        thirdView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thirdView.topAnchor.constraint(equalTo: secondView.bottomAnchor, constant: 0),
            thirdView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            thirdView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            thirdView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
    }
    
    private func configureLogoImageView() {
        firstView.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: firstView.topAnchor, constant: 35),
            logoImageView.centerXAnchor.constraint(equalTo: firstView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalTo: firstView.heightAnchor, multiplier: 0.4),
            logoImageView.widthAnchor.constraint(equalTo: firstView.widthAnchor, multiplier: 0.4)
        ])
    }
    
    private func configureLogoTitleLabel() {
        firstView.addSubview(logoTitleLabel)
        logoTitleLabel.text = "Saffy Cleaning"
        logoTitleLabel.setCharacterSpacing(characterSpacing: 2)
        
        NSLayoutConstraint.activate([
            logoTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 5),
            logoTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoTitleLabel.heightAnchor.constraint(equalTo: firstView.heightAnchor, multiplier: 0.2)
        ])
    }
    
    private func configureLogoSubTitleLabel() {
        firstView.addSubview(logoSubTitleLabel)
        logoSubTitleLabel.numberOfLines = 2
        logoSubTitleLabel.setCharacterSpacing(characterSpacing: 2)
        logoSubTitleLabel.font = .urbanistRegular(size: 25)
        logoSubTitleLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            logoSubTitleLabel.topAnchor.constraint(equalTo: logoTitleLabel.bottomAnchor, constant: 15),
            logoSubTitleLabel.centerXAnchor.constraint(equalTo: firstView.centerXAnchor),
            logoSubTitleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureTextFieldStackView() {
        textFieldStackView = SCStackView(arrangedSubviews: [usernameTextField, passwordTextField])
        secondView.addSubview(textFieldStackView)
        
        passwordTextField.isSecureTextEntry = true
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            usernameTextField.widthAnchor.constraint(equalTo: textFieldStackView.widthAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: textFieldStackView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textFieldStackView.topAnchor.constraint(equalTo: secondView.topAnchor, constant: 20),
            textFieldStackView.leadingAnchor.constraint(equalTo: secondView.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            textFieldStackView.trailingAnchor.constraint(equalTo: secondView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])
    }
    
    private func configureForgetPasswordLabel() {
        secondView.addSubview(forgetPasswordLabel)
        forgetPasswordLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgetPasswordDidTapped(_:)))
        
        forgetPasswordLabel.addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            forgetPasswordLabel.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 5),
            forgetPasswordLabel.trailingAnchor.constraint(equalTo: secondView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            forgetPasswordLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configureButtonStackView() {
        buttonStackView = SCStackView(arrangedSubviews: [loginButton, signUpButton])
        secondView.addSubview(buttonStackView)
        
        loginButton.addTarget(self, action: #selector(loginButtonDidTapped(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonDidTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor),
            signUpButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            signUpButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: forgetPasswordLabel.bottomAnchor, constant: 25),
            buttonStackView.centerXAnchor.constraint(equalTo: secondView.centerXAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: 160),
        ])
    }
    
    private func configureSignInStackView() {
        signInStackView = SCStackView(arrangedSubviews: [googleSignInView, facebookSignInView])
        thirdView.addSubview(signInStackView)
        signInStackView.spacing = 20
        
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(continueWithGoogleDidTapped(_:)))
        let facebookTap = UITapGestureRecognizer(target: self, action: #selector(continueWithFacebookDidTapped(_:)))
        
        googleSignInView.addGestureRecognizer(googleTap)
        facebookSignInView.addGestureRecognizer(facebookTap)
                
        NSLayoutConstraint.activate([
            facebookSignInView.widthAnchor.constraint(equalTo: signInStackView.widthAnchor),
            facebookSignInView.heightAnchor.constraint(equalTo: thirdView.heightAnchor, multiplier: 0.25),
            googleSignInView.widthAnchor.constraint(equalTo: signInStackView.widthAnchor),
            googleSignInView.heightAnchor.constraint(equalTo: thirdView.heightAnchor, multiplier: 0.25)
        ])
        
        NSLayoutConstraint.activate([
            signInStackView.topAnchor.constraint(equalTo: thirdView.topAnchor, constant: 0),
            signInStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            signInStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.count == 0 {
            textField.rightView = nil
            textField.layer.borderColor = UIColor.brandGem.cgColor
        } else {
            textField.layer.borderColor = UIColor.brandGem.cgColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
}
