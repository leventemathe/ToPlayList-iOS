//
//  MyStyledSegmentedView.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class MyStyledSegmentedView: UISegmentedControl, RoundedCorners {

    override func awakeFromNib() {
        addRoundedCorners(self.bounds.size.height / 2.0)
    }
}
