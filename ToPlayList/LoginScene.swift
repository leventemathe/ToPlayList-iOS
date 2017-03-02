//
//  LoginSceneTextField.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoginSceneTextField: UITextField, RoundedCorners, Bordered, TextFieldMargin, CustomClearButton {
    
    static let PLACE_HOLDER_COLOR = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
    
    override func awakeFromNib() {
        addBorder()
        addRoundedCorners(frame.height / 2.0)
        addMargin(10.0)
        addCustomClearButton(#imageLiteral(resourceName: "clear_default"), imageWhenClicked: #imageLiteral(resourceName: "clear_clicked"), withMargin: 10.0)
    }
}

class LoginSceneTextUsername: LoginSceneTextField, ColoredPlaceholderText {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changePlaceholderColor("username", toColor: LoginSceneTextField.PLACE_HOLDER_COLOR)
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
    
    private var loadingAnimationView: NVActivityIndicatorView?
    
    override func awakeFromNib() {
        addRoundedCorners(frame.height / 2.0)
    }
    
    private func setupLoadingAnimation() {
        let width: CGFloat = 20.0
        let height: CGFloat = width
        
        let x: CGFloat = (self.frame.size.width / 2.0) - (width / 2.0)
        let y: CGFloat = (self.frame.size.height / 2.0) - (height / 2.0)
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.white, padding: 0.0)
        
        addSubview(loadingAnimationView!)
    }
    
    func startLoadingAnimation() {
        if loadingAnimationView == nil {
            setupLoadingAnimation()
        }
        titleLabel?.removeFromSuperview()
        loadingAnimationView?.startAnimating()
    }
    
    func stopLoadingAnimation() {
        if loadingAnimationView == nil {
            setupLoadingAnimation()
        }
        addSubview(titleLabel!)
        loadingAnimationView?.stopAnimating()
    }
}






