//
//  RoundedLabels.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class BadgeLabel: UILabel, RoundedCorners {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addRoundedCorners(frame.height / 2.0)
    }
}
