//
//  UpgradeVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class UpgradeVC: UIViewController {
    
    private let NETWORK_ERROR = "No internet connection."
    private let SERVER_ERROR = "There was an error on the server. Please try again later."
    
    private let PRODUCT_NAME = "Premium"
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var upgradeButton: LoginSceneButtonLogin!
    
    @IBAction func upgradeButtonClicked(_ sender: UIButton) {
        InappPurchaseSystem.instance.purchase(product: PRODUCT_NAME)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upgradeButton.startLoadingAnimation()
        InappPurchaseSystem.instance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundImageLeftConstraint.constant = -60
        addTiltingBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeTiltingBackground()
        backgroundImageLeftConstraint.constant = 0
    }
    
    var horizontalMotion: UIInterpolatingMotionEffect?
    var verticalMotion: UIInterpolatingMotionEffect?
    
    private func addTiltingBackground() {
        let amount = 50
        
        if horizontalMotion == nil || verticalMotion == nil {
            horizontalMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            horizontalMotion!.minimumRelativeValue = -amount
            horizontalMotion!.maximumRelativeValue = amount
            
            verticalMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            verticalMotion!.minimumRelativeValue = -amount
            verticalMotion!.maximumRelativeValue = amount
        }
        
        backgroundImageView.addMotionEffect(horizontalMotion!)
        backgroundImageView.addMotionEffect(verticalMotion!)
    }
    
    private func removeTiltingBackground() {
        if let hor = horizontalMotion, let ver = verticalMotion {
            backgroundImageView.removeMotionEffect(hor)
            backgroundImageView.removeMotionEffect(ver)
        }
    }
}

extension UpgradeVC: InappPurchaseSystemDelegate {
    
    func didReceiveProducts(_ products: [String]) {
        print("Received products:\(products)")
        for product in products {
            if let name = product.split(separator: ".").last {
                if name == PRODUCT_NAME {
                    upgradeButton.stopLoadingAnimation()
                    upgradeButton.isEnabled = true
                }
            }
        }
    }
    
    func productRequestFailed(with error: Error) {
        print("Product request failed with error: \(error)")
    }
}