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
    
    @IBOutlet weak var usernameField: LoginSceneTextUsername!
    @IBOutlet weak var emailField: LoginSceneTextFieldEmail!
    @IBOutlet weak var passwordField: LoginSceneTextFieldPassword!
    @IBOutlet weak var errorView: ErrorMessage!
    
    @IBAction func registerClicked(_ sender: LoginSceneButtonLogin) {
        self.errorView.hide()
        
        guard var email = emailField.text, var password = passwordField.text, var username = usernameField.text else {
            return
        }
        
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if username == "" {
            self.errorView.show(withText: "Please provide a username!")
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
        
        // TODO recheck error codes
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = FIRAuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .errorCodeEmailAlreadyInUse:
                    self.errorView.show(withText: "Email is already in use")
                    break
                case .errorCodeInvalidEmail:
                    self.errorView.show(withText: "Invalid email")
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
                self.registerSuccesful(username)
            }
        }
    }
    
    private func registerSuccesful(_ username: String) {
        ListsUser.instance.createUser({ result in
            switch result {
            case .success:
                self.parent!.performSegue(withIdentifier: "LoginToList", sender: self)
            case .failure(let error):
                switch error {
                case .usernameAlreadyInUse:
                    self.errorView.show(withText: "The username is already in use")
                    ListsUser.instance.deleteUserBeforeFullyCreated()
                case .unknownError:
                    self.errorView.show(withText: "An unknown error occured 😟")
                }
            }
        }, withUsername: username)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorView.hide()
    }
}
