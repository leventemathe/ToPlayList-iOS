//
//  BadgeVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class BadgeVC: UICollectionViewController, IdentifiableVC {

    private var strings = [String]()
    
    func add(string: String) {
        strings.append(string)
    }
}
