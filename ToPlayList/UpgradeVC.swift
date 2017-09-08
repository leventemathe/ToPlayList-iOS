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
    
    @IBOutlet weak var upgradeButton: LoginSceneButtonLogin!
    
    @IBAction func upgradeButtonClicked(_ sender: UIButton) {
        
    }
    
    private let api = InappPurchasesService.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getProductIDs { result in
            switch result {
            case .success(let ids):
                print(ids)
            case .failure(let error):
                switch error {
                case .network:
                    Alerts.alertWithOKButton(withMessage: self.NETWORK_ERROR, forVC: self)
                case .server:
                    Alerts.alertWithOKButton(withMessage: self.SERVER_ERROR, forVC: self)
                }
            }
        }
    }
}
