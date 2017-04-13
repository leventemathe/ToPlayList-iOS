//
//  DetailsImages.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class DetailsBigScreenshot: UIView, Gradiented {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let fromColor = UIColor.clear.cgColor
        let midColors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6).cgColor
        ]
        let toColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8).cgColor
        
        addGradient(fromColor: fromColor, midColors: midColors, toColor: toColor)
    }
}

class DetailsCover: UIView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow(1.0, withOffset: CGSize.zero)
    }
}

class StarBanner: UIImageView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow(0.5, withOffset:  CGSize.zero)
    }
}

class StarImage: UIImageView, DropShadowed {
    
    override func awakeFromNib() {
        //addDropShadow(0.5, withOffset: CGSize.zero)
    }
}

class ContainerView: UIView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow(0.5, withOffset: CGSize.zero)
    }
}
