//
//  UpgradeVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class UpgradeVC: UIViewController {
    
    private let UNKNOWN_ERROR = "An error happened, please try again later."
    private let PRODUCT_REQUEST_ERROR = "Failed getting in-app purchase products. Please try again later."
    private let RECEIPT_MISSING_VERIFICATION_ERROR = "Purchase verification failed with error: receipt is missing. Please try again later."
    private let NETWORK_VERIFICATION_ERROR = "Network error while verifying purchase. Please check your internet connection, and try again later."
    private let SERVER_VERIFICATION_ERROR = "Server error while verifying purchase. Please try again later."
    
    private let TRANSACTION_FINISHED_MSG = "Transaction finished. Verifying purchase..."
    
    private let BUTTON_NOT_SUBSCRIBED = "Upgrade"
    private let BUTTON_SUBSCRIBED = "Subscribed"
    private let VERIFICATION_SUCCEEDED = "Verification finished, purchase was successful. Enjoy. 🙂"
    private let VERIFICATION_FAILED = "Verification failed, please try again later."
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var upgradeButton: LoginSceneButtonLogin!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var retryVerificationButton: LoginSceneButtonLogin!
    
    @IBAction func upgradeButtonClicked(_ sender: UIButton) {
        upgradeButton.startLoadingAnimation()
        upgradeButton.isEnabled = false
        InappPurchaseSystem.instance.purchase(product: InappPurchaseSystem.PREMIUM_ID)
    }
    
    @IBAction func retryVerificationClicked(_ sender: LoginSceneButtonLogin) {
        InappPurchaseSystem.instance.verifyReceipt { result in
            switch result {
            case .succeeded:
                InappPurchaseSystem.instance.setReceipt()
                self.setInfoLabel(self.VERIFICATION_SUCCEEDED, color: .green)
                self.retryVerificationButton.isHidden = true
            case .failed:
                self.setInfoLabel(self.VERIFICATION_FAILED, color: .red)
            case .error(let error):
                switch error {
                case .receiptMissing:
                    self.setInfoLabel(self.RECEIPT_MISSING_VERIFICATION_ERROR, color: .red)
                case .network:
                    self.setInfoLabel(self.NETWORK_VERIFICATION_ERROR, color: .red)
                case .server:
                    self.setInfoLabel(self.SERVER_VERIFICATION_ERROR, color: .red)
                }
            }
        }
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

extension UpgradeVC {
    
    private func setInfoLabel(_ text: String, color: UIColor) {
        infoLabel.text = text
        infoLabel.textColor = color
        infoLabel.isHidden = false
    }
    
    private func unsetInfoLabel() {
        infoLabel.isHidden = true
    }
}

extension UpgradeVC: InappPurchaseSystemDelegate {
    
    func didReceiveProducts(_ products: [InappPurchaseProduct]) {
        for product in products {
            if product.id == InappPurchaseSystem.PREMIUM_ID {
                upgradeButton.stopLoadingAnimation()
                upgradeButton.isEnabled = true
                priceLabel.text = product.price
            }
        }
    }
    
    func productRequestFailed(with error: Error) {
        setInfoLabel(PRODUCT_REQUEST_ERROR, color: .red)
        upgradeButton.stopLoadingAnimation()
        upgradeButton.isEnabled = false
    }
    
    func productPurchased(_ product: String) {
        setInfoLabel(TRANSACTION_FINISHED_MSG, color: .green)
    }
    
    func productPurchaseFailed(_ product: String) {
        upgradeButton.stopLoadingAnimation()
        upgradeButton.isEnabled = true
        setInfoLabel(UNKNOWN_ERROR, color: .red)
    }
    
    func productRestored(_ product: String) {
        upgradeButton.stopLoadingAnimation()
        upgradeButton.isEnabled = true
    }
    
    func productVerification(result: InappPurchaseVerificationResult) {
        upgradeButton.stopLoadingAnimation()
        switch result {
        case .succeeded:
            upgradeButton.isEnabled = false
            upgradeButton.setTitle(BUTTON_SUBSCRIBED, for: .disabled)
            setInfoLabel(VERIFICATION_SUCCEEDED, color: .green)
        case .failed:
            upgradeButton.isEnabled = true
            upgradeButton.setTitle(BUTTON_NOT_SUBSCRIBED, for: .normal)
            setInfoLabel(VERIFICATION_FAILED, color: .red)
            retryVerificationButton.isHidden = false
        case .error(let error):
            upgradeButton.isEnabled = true
            upgradeButton.setTitle(BUTTON_NOT_SUBSCRIBED, for: .normal)
            retryVerificationButton.isHidden = false
            switch error {
            case .receiptMissing:
                setInfoLabel(RECEIPT_MISSING_VERIFICATION_ERROR, color: .red)
            case .network:
                setInfoLabel(NETWORK_VERIFICATION_ERROR, color: .red)
            case .server:
                setInfoLabel(SERVER_VERIFICATION_ERROR, color: .red)
            }
        }
    }
}
