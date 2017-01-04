//
//  DropShadow.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 27..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit

protocol DropShadow { }

extension DropShadow where Self: UIView {
    
    func addDropShadow(_ radius: CGFloat = 1.0) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize.zero
    }
}

class ShadowyView: UIView, DropShadow { }
