//
//  MainTabVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 22..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return selectedViewController != viewController
    }
}
