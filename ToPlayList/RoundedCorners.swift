//
//  RoundedCorner.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 27..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit

public protocol RoundedCorners { }

extension RoundedCorners where Self: UIImageView {
    
    func addRoundedCorners(_ amount: CGFloat = 14.0) {
        layer.cornerRadius = amount
    }
}

class ListImageView: UIImageView, RoundedCorners {
    
}
