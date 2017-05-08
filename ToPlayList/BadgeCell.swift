//
//  BadgeCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class BadgeCell: UICollectionViewCell, ReusableView {
    
    @IBOutlet weak var label: BadgeLabel!
    
    func update(_ string: String) {
        label.text = string
    }
}
