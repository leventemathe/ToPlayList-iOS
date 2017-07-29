//
//  SearchIconVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class SearchIconVC: UIViewController {
    
    @IBOutlet weak var searchIcon: UIImageView!
    
    override func viewDidLoad() {
        setupTiltingBackground()
    }
    
    private func setupTiltingBackground() {
        let amount = 50
        
        let horizontalMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotion.minimumRelativeValue = -amount
        horizontalMotion.maximumRelativeValue = amount
        
        let verticalMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotion.minimumRelativeValue = -amount
        verticalMotion.maximumRelativeValue = amount
        
        searchIcon.addMotionEffect(horizontalMotion)
        searchIcon.addMotionEffect(verticalMotion)
    }
}
