//
//  Register.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController, IdentifiableVC {
    
    static let ERROR_EMAIL_ALREADY_IN_USE = "Email already in use"
    static let ERROR_USERNAME_ALREADY_IN_USE = "Username already in use"
    static let ERROR_INVALID_EMAIL = "Invalid email"
    static let ERROR_INVALID_USERNAME = "Invalid username"
    static let ERROR_NO_INTERNET = "No internet"
    static let ERROR_WEAK_PASSWORD = "Password is too weak"
    static let ERROR_UNKNOWN = "Unknown error"
    
    @IBOutlet weak var usernameField: LoginSceneTextUsername!
    @IBOutlet weak var emailField: LoginSceneTextFieldEmail!
    @IBOutlet weak var passwordField: LoginSceneTextFieldPassword!
    @IBOutlet weak var errorView: ErrorMessage!
    
    @IBOutlet weak var registerBtn: LoginSceneButtonLogin!
    
    override func viewWillAppear(_ animated: Bool) {
        errorView.hide()
    }
    
    @IBAction func registerClicked(_ sender: LoginSceneButtonLogin) {
        self.errorView.hide()
        
        if let userData = validate() {
            registerBtn.startLoadingAnimation()
            register(userData.email, withPassword: userData.password, withUsername: userData.username)
        }
    }
    
    private func validate() -> (email: String, password: String, username: String)? {
        guard var email = emailField.text, var password = passwordField.text, var username = usernameField.text else {
            return nil
        }
        
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if username == "" {
            self.errorView.show(withText: "Please provide a username!")
            return nil
        }
        if email == "" {
            self.errorView.show(withText: "Please provide an email address!")
            return nil
        }
        if password == "" {
            self.errorView.show(withText: "Please provide a password!")
            return nil
        }
        
        return (email: email, password: password, username: username)
    }
    
    private func register(_ email: String, withPassword password: String, withUsername username: String) {
        RegisterService.instance.register(withEmail: email, withPassword: password, withUsername: username) { result in
            self.registerBtn.stopLoadingAnimation()
            
            switch result {
            case .success:
                self.parent!.performSegue(withIdentifier: "LoginToList", sender: self)
            case .failure(let error):
                switch error {
                case .emailAlreadyInUse:
                    self.errorView.show(withText: RegisterVC.ERROR_EMAIL_ALREADY_IN_USE)
                case .invalidEmail:
                    self.errorView.show(withText: RegisterVC.ERROR_INVALID_EMAIL)
                case .invalidUsername:
                    self.errorView.show(withText: RegisterVC.ERROR_INVALID_USERNAME)
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .passwordTooWeak:
                    self.errorView.show(withText: RegisterVC.ERROR_WEAK_PASSWORD)
                case .usernameAlreadyInUse:
                    self.errorView.show(withText: RegisterVC.ERROR_USERNAME_ALREADY_IN_USE)
                case .unknown:
                    self.errorView.show(withText: RegisterVC.ERROR_UNKNOWN)
                }
                break
            }
        }
    }
}
