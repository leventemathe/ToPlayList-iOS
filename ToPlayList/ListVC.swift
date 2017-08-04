//
//  ListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class ListVC: UIViewController, IdentifiableVC, UserNotVerifiedDelegate {
    
    private static let WELCOME_MSG = "Welcome"
    
    @IBOutlet weak var userNotVerifiedView: UserNotVerifiedView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var listContainerView: UIView!
    
    @IBOutlet weak var backgroundStarImageView: UIImageView!
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setToPLayListContainer()
            setBackgroundToToPlayList()
        case 1:
            setPlayedListContainer()
            setBackgroundToPlayedList()
        default:
            break
        }
    }
    
    private func setBackgroundToToPlayList() {
        UIView.transition(with: backgroundStarImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.backgroundStarImageView.image = #imageLiteral(resourceName: "to_play_list_bg")
        })
    }
    
    private func setBackgroundToPlayedList() {
        UIView.transition(with: backgroundStarImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.backgroundStarImageView.image = #imageLiteral(resourceName: "played_list_bg")
        })
    }
    
    private lazy var toPLayListVC: ToPlayListVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let toPlayListVC = storyboard.instantiateViewController(withIdentifier: ToPlayListVC.id) as! ToPlayListVC
        return toPlayListVC
    }()
    
    private lazy var playedListVC: PlayedListVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playedListVC = storyboard.instantiateViewController(withIdentifier: PlayedListVC.id) as! PlayedListVC
        return playedListVC
    }()
    
    func setToPLayListContainer() {
        clearPlayedListnContainer()
        addChildViewController(toPLayListVC)
        toPLayListVC.view.frame.size = listContainerView.frame.size
        listContainerView.addSubview(toPLayListVC.view)
        toPLayListVC.didMove(toParentViewController: self)
    }
    
    func setPlayedListContainer() {
        clearToPlayListContainer()
        addChildViewController(playedListVC)
        playedListVC.view.frame.size = listContainerView.frame.size
        listContainerView.addSubview(playedListVC.view)
        playedListVC.didMove(toParentViewController: self)
    }
    
    func clearToPlayListContainer() {
        toPLayListVC.removeFromParentViewController()
        toPLayListVC.view.removeFromSuperview()
    }
    
    func clearPlayedListnContainer() {
        playedListVC.removeFromParentViewController()
        playedListVC.view.removeFromSuperview()
    }
    
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {        
        Alerts.alertWithYesAndNoButtons(withTitle: "Log out", withMessage: "Are you sure, you want to log out?", forVC: self, withOnYes: {
            do {
                ToPlayListNotificationSystem.teardown()
                self.toPLayListVC.removeListeners()
                self.playedListVC.removeListeners()
                try FIRAuth.auth()?.signOut()
                self.backgroundStarImageView.image = nil // so that it doesn't bleed into login screen while removeing vc from stack
                _ = self.navigationController?.popToRootViewController(animated: true)
            } catch _ as NSError {
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_ERROR, forVC: self)
            }
        })
    }
    
    override func viewDidLoad() {
        setupWelcomeMsg()
        setupSegmentedView()
        setupTiltingBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar(animated)
        setupVerification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        welcomeMsgReadyForAnimation.viewAppeared = true
    }
    
    private func setupNavBar(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
    }
    
    private func setupVerification() {
        userNotVerifiedView.delegate = self
        if ListsUser.verified {
            hideUserNotVerifiedView()
        } else {
            showUserNotVerifiedView()
        }
        LoginService.instance.reload({ result in
            switch result {
            case .success:
                if ListsUser.verified {
                    self.hideUserNotVerifiedView()
                }
            case .failure(let error):
                switch error {
                default:
                    print("An error occured while trying to verify user in view will appear: \(error)")
                }
            }
        })

    }
    
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
    
    func userNotVerifiedResendEmailClicked(_ onComplete: @escaping ()->()) {
        VerificationService.instance.sendVerification({ result in
            onComplete()
            switch result {
            case .success:
                Alerts.alertSuccessWithOKButton(withMessage: ListVC.SUCCESS_EMAIL_SENT, forVC: self)
                break
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_EMAIL_SENT, forVC: self)
                }
            }
        })
    }
    
    func userNotVerifiedImVerifiedClicked(_ onComplete: @escaping ()->()) {
        LoginService.instance.reload({ result in
            onComplete()
            switch result {
            case .success:
                if ListsUser.verified {
                    self.hideUserNotVerifiedView()
                } else {
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_NOT_VERIFIED, forVC: self)
                }
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .firebaseError:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_SERVER, forVC: self)
                case .invalidAPIKey:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_SERVER, forVC: self)
                case .tooManyRequests:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_TOO_MANY_REQUESTS, forVC: self)
                case .userDisabled:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_USER_DISABLED, forVC: self)
                case .userTokenExpired:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_USER_TOKEN_EXPIRED, forVC: self)
                case .unknown:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_UNKNOWN, forVC: self)
                default:
                    Alerts.alertWithOKButton(withMessage: ListVC.ERROR_USER_NOT_FOUND, forVC: self)
                }
            }
        })
    }
    
    private func showUserNotVerifiedView() {
        userNotVerifiedView.isHidden = false
    }
    
    private func hideUserNotVerifiedView() {
        userNotVerifiedView.isHidden = true
    }
    
    @IBOutlet weak var welcomLbl: UILabel!
    
    @IBOutlet weak var welcomeLblContainerLeadeingConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeLblContainerTrailingConstraint: NSLayoutConstraint!
    
    private let WELCOME_LBL_STARTING_CONSTRAINT: CGFloat = 1000.0
    private let WELCOME_LBL_FINAL_CONSTRAINT: CGFloat = 8.0
    
    private var welcomeMsgReadyForAnimation = (viewAppeared: false, userNameLoaded: false) {
        didSet {
            if welcomeMsgReadyForAnimation.viewAppeared && welcomeMsgReadyForAnimation.userNameLoaded {
                animateWelcomeMsg()
            }
        }
    }
    
    private func setupWelcomeMsg() {
        let welcomeAttributes: [String: Any] = [
            NSFontAttributeName : UIFont(name: "Silkscreen", size: 18) as Any,
            NSForegroundColorAttributeName : UIColor.MyCustomColors.orange
        ]
        let userAttributes: [String: Any] = [
            NSFontAttributeName : UIFont(name: "Avenir Book", size: 18) as Any,
            NSForegroundColorAttributeName : UIColor.black
        ]
        
        welcomLbl.attributedText = NSMutableAttributedString(string: "\(ListVC.WELCOME_MSG)!", attributes: welcomeAttributes)
        
        welcomeLblContainerLeadeingConstraint.constant = -WELCOME_LBL_STARTING_CONSTRAINT
        welcomeLblContainerTrailingConstraint.constant = WELCOME_LBL_STARTING_CONSTRAINT
        
        guard let uid = ListsUser.userid else {
            return
        }
        ListsEndpoints.USERS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any], let username = value["username"] as? String {
                let welcomeText = NSMutableAttributedString(string: "\(ListVC.WELCOME_MSG)", attributes: welcomeAttributes)
                let userText = NSMutableAttributedString(string: " \(username)", attributes: userAttributes)
                let exclamationPoint = NSMutableAttributedString(string: " !", attributes: welcomeAttributes)
                welcomeText.append(userText)
                welcomeText.append(exclamationPoint)
                self.welcomLbl.attributedText = welcomeText
            }
            self.welcomeMsgReadyForAnimation.userNameLoaded = true
        })
    }
    
    private func animateWelcomeMsg() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [], animations: {
            self.welcomeLblContainerLeadeingConstraint.constant = self.WELCOME_LBL_FINAL_CONSTRAINT
            self.welcomeLblContainerTrailingConstraint.constant = self.WELCOME_LBL_FINAL_CONSTRAINT
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func setupSegmentedView() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            setToPLayListContainer()
        case 1:
            setPlayedListContainer()
        default:
            break
        }
    }
    
    private func setupTiltingBackground() {
        let amount = 50
        
        let horizontalMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotion.minimumRelativeValue = -amount
        horizontalMotion.maximumRelativeValue = amount
        
        let verticalMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotion.minimumRelativeValue = -amount
        verticalMotion.maximumRelativeValue = amount
        
        backgroundStarImageView.addMotionEffect(horizontalMotion)
        backgroundStarImageView.addMotionEffect(verticalMotion)
    }
}
