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
    
    static let VALIDATION_NO_USERDATA = "Please fill in the form below!"
    static let VALIDATION_NO_EMAIL = "Please provide an email address!"
    static let VALIDATION_NO_PASSWORD = "Please provide a password!"
    
    static let ERROR_USER_NOT_FOUND = "Invalid email or password!"
    static let ERROR_TOKEN_EXPIRED = "User token expired!"
    static let ERROR_NO_INTERNET = "No internet!"
    static let ERROR_SERVER = "An error occured on the server. Sorry! 😞"
    static let ERROR_TOO_MANY_REQUESTS = "Too many requests. Please slow down! 😉"
    static let ERROR_USER_DISABLED = "User disabled."
    static let ERROR_USER_TOKEN_EXPIRED = "User token expired. Please log in again!"
    static let ERROR_UNKNOWN = "Unknown error!"
    
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
    
    private func validate() -> UserDataLogin? {
        switch LoginService.instance.validate((email: emailField.text, password: passwordField.text)) {
        case .success(let result):
            return result
        case .failure(let error):
            switch error {
            case .noUserData:
                errorView.show(withText: LoginVC.VALIDATION_NO_USERDATA)
            case .noEmail:
                errorView.show(withText: LoginVC.VALIDATION_NO_EMAIL)
            case .noPassword:
                errorView.show(withText: LoginVC.VALIDATION_NO_PASSWORD)
            }
            return nil
        }
    }
    
    private func login(_ email: String, withPassword password: String) {
        LoginService.instance.login(email, withPassword: password) { result in
            self.loginBtn.stopLoadingAnimation()
            
            switch result {
            case .success:
                self.loginSuccesful()
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .firebaseError:
                    Alerts.alertWithOKButton(withMessage: LoginVC.ERROR_SERVER, forVC: self)
                case .invalidAPIKey:
                    Alerts.alertWithOKButton(withMessage: LoginVC.ERROR_SERVER, forVC: self)
                case .tooManyRequests:
                    Alerts.alertWithOKButton(withMessage: LoginVC.ERROR_TOO_MANY_REQUESTS, forVC: self)
                case .userDisabled:
                    self.errorView.show(withText: LoginVC.ERROR_USER_DISABLED)
                case .userTokenExpired:
                    Alerts.alertWithOKButton(withMessage: LoginVC.ERROR_USER_TOKEN_EXPIRED, forVC: self)
                case .unknown:
                    self.errorView.show(withText: LoginVC.ERROR_UNKNOWN)
                default:
                    self.errorView.show(withText: LoginVC.ERROR_USER_NOT_FOUND)
                }
            }
        }
    }
    
    private func loginSuccesful() {
        resetInput()
        parent!.performSegue(withIdentifier: "LoginToList", sender: self)
    }
    
    private func resetInput() {
        emailField.text = ""
        passwordField.text = ""
        errorView.isHidden = true
        dismissKeyboard()
    }
}
