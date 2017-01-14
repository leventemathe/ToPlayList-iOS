//
//  CustomClearButton.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 14..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol CustomClearButton {
    
}

extension CustomClearButton where Self: UITextField {
    
    func addCustomClearButton(_ normal: UIImage, imageWhenClicked clicked:UIImage, withMargin margin: CGFloat = 0.0) {
        clearButtonMode = .never
        rightViewMode = .whileEditing
        
        let SIZE: CGFloat = 14.0
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: SIZE + margin, height: SIZE))
        let btn = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: SIZE, height: SIZE))
        btn.setImage(normal, for: .normal)
        btn.setImage(clicked, for: .highlighted)
        btn.addTarget(self, action: #selector(UITextField.clear), for: .touchUpInside)
        view.addSubview(btn)
        rightView = view
    }
}

extension UITextField {
    
    @objc func clear() {
        text = ""
    }
}
