//
//  LoginVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FirebaseAuth

extension UILabel {
    
    func show(withText text: String) {
        self.text = text
    }
    
    func hide() {
        self.text = ""
    }
}

class LoginVC: UIViewController, IdentifiableVC {
    
    @IBOutlet weak var emailField: LoginSceneTextFieldEmail!
    @IBOutlet weak var passwordField: LoginSceneTextFieldPassword!
    @IBOutlet weak var errorView: ErrorMessage!

    @IBAction func loginClicked(_ sender: LoginSceneButtonLogin) {
        if let email = emailField.text, let password = passwordField.text {
            
            self.errorView.hide()
            
            // trim white space
            
            if email == "" && password == "" {
                self.errorView.show(withText: "Please provide an email adress and a password!")
                return
            }
            if email == "" {
                self.errorView.show(withText: "Please provide an email adress!")
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
                        self.register()
                    case .errorCodeEmailAlreadyInUse:
                        self.errorView.show(withText: "Email is already in use")
                        break
                    case .errorCodeInvalidEmail:
                        self.errorView.show(withText: "Invalid email adress")
                        break
                    case .errorCodeNetworkError:
                        // TODO alert
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
                        self.errorView.show(withText: "An unknown error occured")
                        break
                    }
                } else {
                    self.loginSuccesful()
                }
            }
        }
    }
    
    func register() {
        
    }
    
    func loginSuccesful() {
        performSegue(withIdentifier: "LoginToList", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
