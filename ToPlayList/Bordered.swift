//
//  Bordered.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol Bordered {
    
}

extension Bordered where Self: UITextField {
    
    func addBorder(_ color: CGColor = UIColor.white.cgColor, withWidth width: CGFloat = 2.0) {
        layer.borderColor = color
        layer.borderWidth = width
    }
}
