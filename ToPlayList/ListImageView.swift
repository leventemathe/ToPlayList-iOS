//
//  ListImageView.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ListImageView: UIImageView, RoundedCorners {
 
    override func awakeFromNib() {
        addRoundedCorners()
    }
}
