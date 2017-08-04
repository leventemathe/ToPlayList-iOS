//
//  ForgotPasswordVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, IdentifiableVC {
    
    @IBOutlet weak var emailTextField: ForgotPasswordSceneTextfieldEmail!
    @IBOutlet weak var requestButton: LoginSceneButtonLogin!
    @IBOutlet weak var errorView: ErrorMessage!
    
    @IBAction func requestClicked(_ sender: LoginSceneButtonLogin) {
        if let parent = parent as? RegisterLoginVC {
            parent.setLoginContainer()
        }
    }
    
    override func viewDidLoad() {
        errorView.isHidden = true
    }
}
