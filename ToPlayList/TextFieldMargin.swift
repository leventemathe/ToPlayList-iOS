//
//  TextFieldMargin.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 14..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol TextFieldMargin { }

extension TextFieldMargin where Self: UITextField {
    
    func addMargin(_ margin: CGFloat = 10.0) {
        let leftMargin = UIView(frame: CGRect(x: 0.0, y: 0.0, width: margin, height: bounds.height))
        leftView = leftMargin
        leftViewMode = .always
    }
}
