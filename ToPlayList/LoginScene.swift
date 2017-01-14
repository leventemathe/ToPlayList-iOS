//
//  LoginSceneTextField.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class LoginSceneTextField: UITextField, RoundedCorners, Bordered, TextFieldMargin, CustomClearButton {
    
    static let PLACE_HOLDER_COLOR = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
    
    override func awakeFromNib() {
        addBorder()
        addRoundedCorners(frame.height / 2.0)
        addMargin(10.0)
        addCustomClearButton(#imageLiteral(resourceName: "clear_default"), imageWhenClicked: #imageLiteral(resourceName: "clear_clicked"), withMargin: 10.0)
    }
}

class LoginSceneTextFieldEmail: LoginSceneTextField, ColoredPlaceholderText {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changePlaceholderColor("email", toColor: LoginSceneTextField.PLACE_HOLDER_COLOR)
    }
}

class LoginSceneTextFieldPassword: LoginSceneTextField, ColoredPlaceholderText {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changePlaceholderColor("password", toColor: LoginSceneTextField.PLACE_HOLDER_COLOR)
    }
}

class LoginSceneButtonLogin: UIButton, RoundedCorners {
    
    override func awakeFromNib() {
        addRoundedCorners(frame.height / 2.0)
    }
}
