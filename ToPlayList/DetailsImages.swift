//
//  DetailsImages.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class DetailsBigScreenshot: UIView, Blurred {

    override func awakeFromNib() {
        addDarkBlur()
    }
}

class DetailsCover: UIView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow()
    }
}
