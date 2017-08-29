//
//  ForgotPasswordVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, IdentifiableVC {
    
    static let VALIDATION_NO_EMAIL = "Please provide an email address."
    static let ERROR_INVALID_EMAIL = "Invalid email."
    static let ERROR_SERVER = "An error occured on the server. Sorry! 😞"
    static let ERROR_UNKNOWN = "Unknown error."
    static let ERROR_NO_INTERNET = "No internet connection."
    static let ERROR_TOO_MANY_REQUESTS = "Too many requests. Please slow down. 😉"
    static let ERROR_USER_DISABLED = "User disabled."
    static let ERROR_USER_NOT_FOUND = "Email not found."
    
    static let SUCCESS_EMAIL_SENT = "Password reset email sent."
    
    @IBOutlet weak var emailTextField: ForgotPasswordSceneTextfieldEmail!
    @IBOutlet weak var requestButton: LoginSceneButtonLogin!
    @IBOutlet weak var errorView: ErrorMessage!
    
    @IBAction func requestClicked(_ sender: LoginSceneButtonLogin) {
        if let email = validate() {
            requestButton.startLoadingAnimation()
            sendRequests(email)
        }
    }
    
    @IBAction func backToLoginClicked(_ sender: UIButton) {
        backToLogin()
    }
    
    private func validate() -> String? {
        switch ForgotPasswordService.instance.validate(emailTextField.text) {
        case .success(let email):
            return email
        case .failure(let error):
            switch error {
            case .noEmail:
                errorView.show(withText: ForgotPasswordVC.VALIDATION_NO_EMAIL)
            }
            return nil
        }
    }
    
    private func sendRequests(_ email: String) {
        ForgotPasswordService.instance.sendRequest(email, withOnComplete: { result in
            self.requestButton.stopLoadingAnimation()
            
            switch result {
            case .success:
                Alerts.alertSuccessWithOKButton(withMessage: ForgotPasswordVC.SUCCESS_EMAIL_SENT , forVC: self)
                self.backToLogin()
            case .failure(let error):
                switch error {
                case .invalidEmail:
                    self.errorView.show(withText: ForgotPasswordVC.ERROR_INVALID_EMAIL)
                case .userNotFound:
                    self.errorView.show(withText: ForgotPasswordVC.ERROR_USER_NOT_FOUND)
                case .firebaseError:
                    Alerts.alertWithOKButton(withMessage: ForgotPasswordVC.ERROR_SERVER, forVC: self)
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: ForgotPasswordVC.ERROR_NO_INTERNET, forVC: self)
                case .tooManyRequests:
                    Alerts.alertWithOKButton(withMessage: ForgotPasswordVC.ERROR_TOO_MANY_REQUESTS, forVC: self)
                case .userDisabled:
                    self.errorView.show(withText: ForgotPasswordVC.ERROR_USER_DISABLED)
                case .unknown:
                    self.errorView.show(withText: ForgotPasswordVC.ERROR_UNKNOWN)
                }
            }
        })
    }
    
    private func backToLogin() {
        if let parent = parent as? RegisterLoginVC {
            resetInput()
            parent.setLoginContainer()
        }
    }
    
    private func resetInput() {
        emailTextField.text = ""
        errorView.isHidden = true
        dismissKeyboard()
    }
    
    override func viewDidLoad() {
        errorView.isHidden = true
    }
}
