//
//  ReusableView.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 27..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit

protocol ReusableView { }

extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
