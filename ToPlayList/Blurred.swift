//
//  Blurred.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol Blurred {
    
    func addDarkBlur()
    func addLightBlur()
}

extension Blurred where Self: UIView {
    
    func addDarkBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func addLightBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}
