//
//  RegisterLoginVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

extension UIViewController
{
    func addTapGestureToHideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

class RegisterLoginVC: UIViewController, IdentifiableVC {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
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
    
    private lazy var forgotPWVC: ForgotPasswordVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forgotPWVC = storyboard.instantiateViewController(withIdentifier: ForgotPasswordVC.id) as! ForgotPasswordVC
        return forgotPWVC
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
        clearForgotPWContainer()
        addChild(registerVC)
        registerVC.view.frame.size = containerView.frame.size
        containerView.addSubview(registerVC.view)
        registerVC.didMove(toParent: self)
        animateVCAppearance(registerVC)
    }
    
    func setLoginContainer() {
        clearRegisterContainer()
        clearForgotPWContainer()
        addChild(loginVC)
        loginVC.view.frame.size = containerView.frame.size
        containerView.addSubview(loginVC.view)
        loginVC.didMove(toParent: self)
        animateVCAppearance(loginVC)
    }
    
    func setForgotPWContainer() {
        clearRegisterContainer()
        clearLoginContainer()
        addChild(forgotPWVC)
        forgotPWVC.view.frame.size = containerView.frame.size
        containerView.addSubview(forgotPWVC.view)
        forgotPWVC.didMove(toParent: self)
        animateVCAppearance(forgotPWVC)
    }

    private func animateVCAppearance(_ vc: UIViewController) {
        vc.view.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            vc.view.alpha = 1.0
        })
    }
    
    func clearRegisterContainer() {
        registerVC.removeFromParent()
        registerVC.view.removeFromSuperview()
    }
    
    func clearLoginContainer() {
        loginVC.removeFromParent()
        loginVC.view.removeFromSuperview()
    }
    
    func clearForgotPWContainer() {
        forgotPWVC.removeFromParent()
        forgotPWVC.view.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        addTapGestureToHideKeyboard()
        setupKeyboardNotifications()
        setupSegmentedView()
        setupTiltingBackground()
        setupStackViewAnimation()
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupSegmentedView() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            setRegisterContainer()
        case 1:
            setLoginContainer()
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
        
        backgroundImageView.addMotionEffect(horizontalMotion)
        backgroundImageView.addMotionEffect(verticalMotion)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    private var topStartingConst: CGFloat!
    private var topAnimatedConst: CGFloat!
    
    private func setupStackViewAnimation() {
        topStartingConst = stackViewTopConstraint.constant
        topAnimatedConst = -150.0
    }
    
    private func animateStackViewUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.stackViewTopConstraint.constant = self.topAnimatedConst
            self.view.layoutIfNeeded()
        })
    }
    
    private func animateStackViewDown() {
        UIView.animate(withDuration: 0.3, animations: {
            self.stackViewTopConstraint.constant = self.topStartingConst
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillAppear() {
        animateStackViewUp()
    }
    
    @objc func keyboardWillDisappear() {
        animateStackViewDown()
    }
}






