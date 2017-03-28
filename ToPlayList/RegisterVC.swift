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
    
    static let VALIDATION_NO_USERDATA = "Please fill in the form below!"
    static let VALIDATION_NO_EMAIL = "Please provide an email address!"
    static let VALIDATION_NO_PASSWORD = "Please provide a password!"
    static let VALIDATION_NO_USERNAME = "Please provide a username!"
    static let VALIDATION_FORBIDDEN_CHAR_IN_USERNAME = "Forbidden character in username!"
    static let VALIDATION_TOO_LONG_USERNAME = "Username is too long! (Max: \(RegisterService.USERNAME_MAX_LENGTH))"
    static let VALIDATION_INVALID_EMAIL = "Invalid email!"
    static let VALIDATION_TOO_LONG_EMAIL = "The email address is too long!"
    static let VALIDATION_NO_CAPITAL_IN_PASSWORD = "The password has to contain a capital letter!"
    static let VALIDATION_NO_NUMBER_IN_PASSWORD = "The password has to contain a number!"
    static let VALIDATION_TOO_LONG_PASSWORD = "The password is too long!"
    static let VALIDATION_TOO_SHORT_PASSWORD = "The password is too short!"
    
    static let ERROR_EMAIL_ALREADY_IN_USE = "Email already in use!"
    static let ERROR_USERNAME_ALREADY_IN_USE = "Username already in use!"
    static let ERROR_INVALID_EMAIL = "Invalid email!"
    static let ERROR_INVALID_USERNAME = "Invalid username!"
    static let ERROR_NO_INTERNET = "No internet!"
    static let ERROR_WEAK_PASSWORD = "Password is too weak!"
    static let ERROR_UNKNOWN = "Unknown error!"
    
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
        
        if let userData = self.validate() {
            registerBtn.startLoadingAnimation()
            register(userData.email, withPassword: userData.password, withUsername: userData.username)
        }
    }
    
    private func validate() -> UserData? {
        switch RegisterService.instance.validate((email: emailField.text, password: passwordField.text, username: usernameField.text)) {
        case .success(let result):
            return result
        case .failure(let error):
            switch error {
            case .noUserData:
                errorView.show(withText: RegisterVC.VALIDATION_NO_USERDATA)
            case .noEmail:
                errorView.show(withText: RegisterVC.VALIDATION_NO_EMAIL)
            case .noPassword:
                errorView.show(withText: RegisterVC.VALIDATION_NO_PASSWORD)
            case .noUsername:
                errorView.show(withText: RegisterVC.VALIDATION_NO_USERNAME)
            case .forbiddenCharacterInUsername(let forbiddenChar):
                errorView.show(withText: RegisterVC.VALIDATION_FORBIDDEN_CHAR_IN_USERNAME + " \"\(forbiddenChar)\"")
            case .tooLongUsername:
                errorView.show(withText: RegisterVC.VALIDATION_TOO_LONG_USERNAME)
            case .invalidEmail:
                errorView.show(withText: RegisterVC.VALIDATION_INVALID_EMAIL)
            case .tooLongEmail:
                errorView.show(withText: RegisterVC.VALIDATION_TOO_LONG_EMAIL)
            case .noCapitalInPassword:
                errorView.show(withText: RegisterVC.VALIDATION_NO_CAPITAL_IN_PASSWORD)
            case .noNumberInPassword:
                errorView.show(withText: RegisterVC.VALIDATION_NO_NUMBER_IN_PASSWORD)
            case .tooLongPassword:
                errorView.show(withText: RegisterVC.VALIDATION_TOO_LONG_PASSWORD)
            case .tooShortPassword:
                errorView.show(withText: RegisterVC.VALIDATION_TOO_SHORT_PASSWORD)
                
            }
            return nil
        }
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
