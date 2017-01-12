//
//  LoginSceneTextField.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class LoginSceneTextField: UITextField, RoundedCorners, Bordered {
    
    override func awakeFromNib() {
        addBorder()
        addRoundedCorners(15.0)
    }
}

class LoginSceneTextFieldEmail: LoginSceneTextField, ColoredPlaceholderText {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changePlaceholderColor("email", toColor: UIColor.white)
    }
}

class LoginSceneTextFieldPassword: LoginSceneTextField, ColoredPlaceholderText {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changePlaceholderColor("password", toColor: UIColor.white)
    }
}
