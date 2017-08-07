//
//  UserNotVerifiedVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 07..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import Firebase

class UserNotVerifiedVC: UIViewController {
    
    static let SUCCESS_EMAIL_SENT = "Verification email sent."
    static let ERROR_EMAIL_SENT = "An error occured while sending verification email after registration."
    static let ERROR_NOT_VERIFIED = "You are not verified!"
    
    static let ERROR_USER_NOT_FOUND = "Invalid email or password!"
    static let ERROR_TOKEN_EXPIRED = "User token expired!"
    static let ERROR_NO_INTERNET = "No internet connection!"
    static let ERROR_SERVER = "An error occured on the server. Sorry! 😞"
    static let ERROR_TOO_MANY_REQUESTS = "Too many requests. Please slow down! 😉"
    static let ERROR_USER_DISABLED = "User disabled."
    static let ERROR_USER_TOKEN_EXPIRED = "User token expired. Please log in again!"
    static let ERROR_UNKNOWN = "Unknown error!"
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var resendEmailButton: LoginSceneButtonLogin!
    @IBOutlet weak var imVerifiedButton: LoginSceneButtonLogin!
    
    @IBAction func resendEmailClicked(_ sender: LoginSceneButtonLogin) {
        resendEmailButton.startLoadingAnimation()
        
        VerificationService.instance.sendVerification({ result in
            self.resendEmailButton.stopLoadingAnimation()
            switch result {
            case .success:
                Alerts.alertSuccessWithOKButton(withMessage: UserNotVerifiedVC.SUCCESS_EMAIL_SENT, forVC: self)
                break
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_EMAIL_SENT, forVC: self)
                }
            }
        })
    }
    
    @IBAction func imVerifiedClicked(_ sender: LoginSceneButtonLogin) {
        imVerifiedButton.startLoadingAnimation()
        
        LoginService.instance.reload({ result in
            self.imVerifiedButton.stopLoadingAnimation()
            switch result {
            case .success:
                if ListsUser.verified {
                    self.performSegue(withIdentifier: "VerificationToLists", sender: self)
                } else {
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_NOT_VERIFIED, forVC: self)
                }
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .firebaseError:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_SERVER, forVC: self)
                case .invalidAPIKey:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_SERVER, forVC: self)
                case .tooManyRequests:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_TOO_MANY_REQUESTS, forVC: self)
                case .userDisabled:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_USER_DISABLED, forVC: self)
                case .userTokenExpired:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_USER_TOKEN_EXPIRED, forVC: self)
                case .unknown:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_UNKNOWN, forVC: self)
                default:
                    Alerts.alertWithOKButton(withMessage: UserNotVerifiedVC.ERROR_USER_NOT_FOUND, forVC: self)
                }
            }
        })
    }
    
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        Alerts.alertWithYesAndNoButtons(withTitle: "Log out", withMessage: "Are you sure, you want to log out?", forVC: self, withOnYes: {
            do {
                try FIRAuth.auth()?.signOut()
                _ = self.navigationController?.popToRootViewController(animated: true)
            } catch _ as NSError {
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_ERROR, forVC: self)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupTiltingBackground()
    }
    
    private func setupNavBar(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
    }
    
    private func setupTiltingBackground() {
        let amount = 50
        
        let horizontalMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotion.minimumRelativeValue = -amount
        horizontalMotion.maximumRelativeValue = amount
        
        let verticalMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotion.minimumRelativeValue = -amount
        verticalMotion.maximumRelativeValue = amount
        
        backgroundView.addMotionEffect(horizontalMotion)
        backgroundView.addMotionEffect(verticalMotion)
    }
}
