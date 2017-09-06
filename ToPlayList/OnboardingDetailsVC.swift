//
//  OnboardingVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 30..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class OnboardingDetailsVC: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var iphoneImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var startButtonContainer: UIView!
    @IBOutlet weak var startButtonContainerTopConstraint: NSLayoutConstraint!
    
    var lastVCInPageVC = false
    
    var iphoneImage: UIImage?
    var titleText: String?
    var text: String?
    var shouldFlipBackground = false
    
    func setup(iphoneImage: UIImage, title: String, text: String, backgroundFlipped: Bool = false) {
        self.iphoneImage = iphoneImage
        self.titleText = title
        self.text = text
        self.shouldFlipBackground = backgroundFlipped
    }
    
    override func viewWillAppear(_ animated: Bool) {
        iphoneImageView.image = iphoneImage
        titleLabel.text = titleText
        textLabel.text = text
        if shouldFlipBackground {
            backgroundImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if lastVCInPageVC && startButtonContainer.isHidden {
            animateStartButtonAppearance()
        }
    }
    
    private func animateStartButtonAppearance() {
        startButtonContainer.isHidden = false
        startButtonContainerTopConstraint.constant = -400
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: [], animations: {
            self.startButtonContainerTopConstraint.constant = -40
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
