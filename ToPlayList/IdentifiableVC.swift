//
//  IdentifiableView.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 15..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol IdentifiableVC { }

extension IdentifiableVC where Self: UIViewController {
    
    static var id: String {
        return String(describing: self)
    }
}
