//
//  OnboardingVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 30..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class OnboardingDetailsVC: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var iphoneImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    var lastVCInPageVC = false
    
    var iphoneImage: UIImage?
    var titleText: String?
    var text: String?
    
    func setup(iphoneImage: UIImage, title: String, text: String) {
        self.iphoneImage = iphoneImage
        self.titleText = title
        self.text = text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        iphoneImageView.image = iphoneImage
        titleLabel.text = titleText
        textLabel.text = text
        startButton.isHidden = !lastVCInPageVC
    }
}
