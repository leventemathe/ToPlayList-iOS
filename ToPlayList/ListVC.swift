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

class ListVC: UIViewController, IdentifiableVC, LoadingAnimationDelegate {
    
    private static let WELCOME_MSG = "Welcome"
    
    var loadingAnimationView: NVActivityIndicatorView!

    @IBOutlet weak var welcomeLbl: UILabel!
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
        toPLayListVC.loadingAnimationDelegate = self
    }
    
    func setPlayedListContainer() {
        clearToPlayListContainer()
        addChildViewController(playedListVC)
        playedListVC.view.frame.size = listContainerView.frame.size
        listContainerView.addSubview(playedListVC.view)
        playedListVC.didMove(toParentViewController: self)
        //TODO set loading animation delegate
    }
    
    func clearToPlayListContainer() {
        toPLayListVC.removeFromParentViewController()
        toPLayListVC.view.removeFromSuperview()
        toPLayListVC.loadingAnimationDelegate = nil
    }
    
    func clearPlayedListnContainer() {
        playedListVC.removeFromParentViewController()
        playedListVC.view.removeFromSuperview()
        //TODO unset loading animation delegate
    }
    
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        
        // TODO are you sure you want to log out
        
        do {
            try FIRAuth.auth()?.signOut()
            _ = navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            // TODO error handling
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        setupWelcomeMsg()
        setupSegmentedView()
        setupTiltingBackground()
        setupLoadingAnimation()
        loadingAnimationView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar(animated)
    }
    
    private func setupNavBar(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
    }
    
    private func setupWelcomeMsg() {
        welcomeLbl.text = "\(ListVC.WELCOME_MSG)!"
        
        guard let uid = ListsUser.userid else {
            return
        }
        ListsEndpoints.USERS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any], let username = value["username"] as? String {
                self.welcomeLbl.text = "\(ListVC.WELCOME_MSG) \(username)!"
            }
        })
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
    
    private func setupLoadingAnimation() {
        let width: CGFloat = 80.0
        let height: CGFloat = width
        
        let x = UIScreen.main.bounds.size.width / 2.0 - width / 2.0
        let y = UIScreen.main.bounds.size.height / 2.0 - height / 2.0
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.MyCustomColors.orange, padding: 0.0)
        view.addSubview(loadingAnimationView)
    }
    
    func startAnimating() {
        print("startanimating called")
        loadingAnimationView.startAnimating()
    }
    
    func stopAnimating() {
        print("stopanimating called")
        loadingAnimationView.stopAnimating()
    }
}
