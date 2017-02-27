//
//  DropShadowed.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 27..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol DropShadowed {
    func addDropShadow(_ radius: CGFloat, withOffset offset: CGSize)
}

extension DropShadowed where Self: UIView {
    
    func addDropShadow(_ radius: CGFloat = 1.0, withOffset offset: CGSize = CGSize.zero) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
}
