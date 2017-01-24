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
    
    @IBOutlet weak var emailField: LoginSceneTextFieldEmail!
    @IBOutlet weak var passwordField: LoginSceneTextFieldPassword!
    @IBOutlet weak var errorView: ErrorMessage!

    @IBAction func loginClicked(_ sender: LoginSceneButtonLogin) {
        self.errorView.hide()
        
        if var email = emailField.text, var password = passwordField.text {
            
            email = email.trimmingCharacters(in: .whitespacesAndNewlines)
            password = password.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if email == "" && password == "" {
                self.errorView.show(withText: "Please provide an email address and a password!")
                return
            }
            if email == "" {
                self.errorView.show(withText: "Please provide an email address!")
                return
            }
            if password == "" {
                self.errorView.show(withText: "Please provide a password!")
                return
            }
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if let error = error, let errorCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .errorCodeUserNotFound:
                        self.register(withEmail: email, withPassword: password)
                    case .errorCodeEmailAlreadyInUse:
                        self.errorView.show(withText: "Email is already in use")
                        break
                    case .errorCodeInvalidEmail:
                        self.errorView.show(withText: "Invalid email adress")
                        break
                    case .errorCodeNetworkError:
                        Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                        break
                    case .errorCodeUserTokenExpired:
                        self.errorView.show(withText: "Session expired. Please log in again!")
                        break
                    case .errorCodeWrongPassword:
                        self.errorView.show(withText: "Wrong password!")
                        break
                    case .errorCodeWeakPassword:
                        self.errorView.show(withText: "The password is too weak")
                        break
                    default:
                        self.errorView.show(withText: "An unknown error occured 😟")
                        break
                    }
                } else {
                    self.loginSuccesful()
                }
            }
        }
    }
    
    private func register(withEmail email: String, withPassword password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = FIRAuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .errorCodeEmailAlreadyInUse:
                    self.errorView.show(withText: "Email is already in use")
                    break
                case .errorCodeNetworkError:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                    break
                case .errorCodeWeakPassword:
                    self.errorView.show(withText: "The password is too weak")
                    break
                default:
                    self.errorView.show(withText: "An unknown error occured 😟")
                    break
                }
            } else {
                if let user = user {
                    User.instance.createUser()
                    self.loginSuccesful()
                } else {
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_ERROR, forVC: self)
                }
            }
        }
    }
    
    private func loginSuccesful() {
        performSegue(withIdentifier: "LoginToList", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorView.hide()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
