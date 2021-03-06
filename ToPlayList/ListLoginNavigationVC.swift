//
//  ListLoginNavigationVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ListLoginNavigationVC: NavigationControllerWithCustomBackGestureDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickVC()
    }
    
    private func pickVC() {
        if ListsUser.loggedIn {
            if ListsUser.verified {
                viewControllers[0].performSegue(withIdentifier: "RegisterLoginToListsNonAnimated", sender: self)
            } else {
                viewControllers[0].performSegue(withIdentifier: "RegisterLoginToVerification", sender: self)
            }
        }
    }
}
