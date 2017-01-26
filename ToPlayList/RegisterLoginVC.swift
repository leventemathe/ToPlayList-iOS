//
//  RegisterLoginVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class RegisterLoginVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    private lazy var loginVC: LoginVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: LoginVC.id) as! LoginVC
        return loginVC
    }()
    
    private lazy var registerVC: RegisterVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: RegisterVC.id) as! RegisterVC
        return registerVC
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedConrolChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setRegisterContainer()
        case 1:
            setLoginContainer()
        default:
            break
        }
    }
    
    func setRegisterContainer() {
        clearLoginContainer()
        addChildViewController(registerVC)
        registerVC.view.frame.size = containerView.frame.size
        containerView.addSubview(registerVC.view)
        registerVC.didMove(toParentViewController: self)
    }
    
    func setLoginContainer() {
        clearRegisterContainer()
        addChildViewController(loginVC)
        loginVC.view.frame.size = containerView.frame.size
        containerView.addSubview(loginVC.view)
        loginVC.didMove(toParentViewController: self)
    }

    func clearRegisterContainer() {
        registerVC.removeFromParentViewController()
        registerVC.view.removeFromSuperview()
    }
    
    func clearLoginContainer() {
        loginVC.removeFromParentViewController()
        loginVC.view.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            setRegisterContainer()
        case 1:
            setLoginContainer()
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
