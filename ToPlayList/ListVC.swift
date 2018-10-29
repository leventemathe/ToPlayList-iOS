//
//  ListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

class ListVC: UIViewController, IdentifiableVC {
    
    private static let WELCOME_MSG = "Welcome"
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var listContainerView: UIView!
    
    @IBOutlet weak var backgroundStarImageView: UIImageView!
    
    @IBOutlet weak var listContainerBottomConstraint: NSLayoutConstraint!
    
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
        addChild(toPLayListVC)
        toPLayListVC.view.frame.size = listContainerView.frame.size
        listContainerView.addSubview(toPLayListVC.view)
        toPLayListVC.didMove(toParent: self)
    }
    
    func setPlayedListContainer() {
        clearToPlayListContainer()
        addChild(playedListVC)
        playedListVC.view.frame.size = listContainerView.frame.size
        listContainerView.addSubview(playedListVC.view)
        playedListVC.didMove(toParent: self)
    }
    
    func clearToPlayListContainer() {
        toPLayListVC.removeFromParent()
        toPLayListVC.view.removeFromSuperview()
    }
    
    func clearPlayedListnContainer() {
        playedListVC.removeFromParent()
        playedListVC.view.removeFromSuperview()
    }
    
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {        
        Alerts.alertWithYesAndNoButtons(withTitle: "Log out", withMessage: "Are you sure, you want to log out?", forVC: self, withOnYes: {
            do {
                ToPlayListNotificationSystem.teardown()
                self.toPLayListVC.removeListeners()
                self.playedListVC.removeListeners()
                try Auth.auth().signOut()
                self.backgroundStarImageView.image = nil // so that it doesn't bleed into login screen while removeing vc from stack
                _ = self.navigationController?.popToRootViewController(animated: true)
            } catch _ as NSError {
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_ERROR, forVC: self)
            }
        })
    }
    
    private var connectionListener: ListsListenerReference?
    @IBOutlet weak var connectionLabel: UILabel!
    
    override func viewDidLoad() {
        setupWelcomeMsg()
        setupSegmentedView()
        setupTiltingBackground()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar(animated)
        attachConnectionListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        welcomeMsgReadyForAnimation.viewAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detachConnectionListener()
    }
    
    private func setupNavBar(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
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
        let welcomeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont(name: "Silkscreen", size: 18) as Any,
            NSAttributedString.Key.foregroundColor : UIColor.MyCustomColors.orange
        ]
        let userAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont(name: "Avenir Book", size: 18) as Any,
            NSAttributedString.Key.foregroundColor : UIColor.black
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
    
    private func attachConnectionListener() {
        connectionListener = ListsConnection.attachListenerForConnection({ connected in
            if connected {
                self.connectionLabel.isHidden = true
            } else {
                self.connectionLabel.isHidden = false
            }
        })
    }
    
    private func detachConnectionListener() {
        connectionListener?.removeListener()
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
    
    private func setupBackButton() {
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back_button")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back_button")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
