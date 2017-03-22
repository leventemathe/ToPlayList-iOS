//
//  LoginVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginVC: UIViewController, IdentifiableVC {
    
    static let ERROR_INVALID_EMAIL = "Invalid email"
    static let ERROR_INVALID_PASSWORD = "Invalid password"
    static let ERROR_USER_NOT_FOUND = "User not found"
    static let ERROR_TOKEN_EXPIRED = "User token expired"
    static let ERROR_NO_INTERNET = "No internet"
    static let ERROR_UNKNOWN = "Unknown error"
    
    @IBOutlet weak var emailField: LoginSceneTextFieldEmail!
    @IBOutlet weak var passwordField: LoginSceneTextFieldPassword!
    @IBOutlet weak var errorView: ErrorMessage!
    
    @IBOutlet weak var loginBtn: LoginSceneButtonLogin!
    
    override func viewWillAppear(_ animated: Bool) {
        errorView.hide()
    }
    
    @IBAction func loginClicked(_ sender: LoginSceneButtonLogin) {
        self.errorView.hide()
        if let userData = validate() {
            loginBtn.startLoadingAnimation()
            login(userData.email, withPassword: userData.password)
        }
    }
    
    private func validate() -> (email: String, password: String)? {
        guard var email = emailField.text, var password = passwordField.text else {
            return nil
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email == "" {
            self.errorView.show(withText: "Please provide an email address!")
            return nil
        }
        if password == "" {
            self.errorView.show(withText: "Please provide a password!")
            return nil
        }
        
        return (email: email, password: password)
    }
    
    private func login(_ email: String, withPassword password: String) {
        LoginService.instance.login(email, withPassword: password) { result in
            self.loginBtn.stopLoadingAnimation()
            
            switch result {
            case .success:
                self.loginSuccesful()
            case .failure(let error):
                switch error {
                case .invalidEmail:
                    self.errorView.show(withText: LoginVC.ERROR_INVALID_EMAIL)
                case .invalidPassword:
                    self.errorView.show(withText: LoginVC.ERROR_INVALID_PASSWORD)
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .userNotFound:
                    self.errorView.show(withText: LoginVC.ERROR_USER_NOT_FOUND)
                case .userTokenExpired:
                    self.errorView.show(withText: LoginVC.ERROR_TOKEN_EXPIRED)
                case .unknown:
                    self.errorView.show(withText: LoginVC.ERROR_UNKNOWN)
                }
            }
        }
    }
    
    private func loginSuccesful() {
        parent!.performSegue(withIdentifier: "LoginToList", sender: self)
    }
}
