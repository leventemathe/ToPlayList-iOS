//
//  OutTodayBadge.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 27..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class OutTodayBadge: UILabel, RoundedCorners {
    
    override func awakeFromNib() {
        addRoundedCorners(self.frame.size.height / 2.0)
    }
}
