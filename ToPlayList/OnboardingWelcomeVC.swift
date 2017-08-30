//
//  OnboardingWelcomeVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 30..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class OnboardingWelcomeVC: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        backgroundImageView.addMotionEffect(horizontalMotion)
        backgroundImageView.addMotionEffect(verticalMotion)
    }
}
