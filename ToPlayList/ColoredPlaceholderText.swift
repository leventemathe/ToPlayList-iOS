//
//  ColoredPlaceholderText.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol ColoredPlaceholderText {
    
}

extension ColoredPlaceholderText where Self: UITextField {
    
    func changePlaceholderColor(_ text: String, toColor color: UIColor) {
        let str = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color])
        attributedPlaceholder = str
    }
}

