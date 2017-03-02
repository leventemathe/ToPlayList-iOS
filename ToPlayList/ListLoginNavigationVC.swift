//
//  ListLoginNavigationVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ListLoginNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        pickVC()
    }
    
    private func pickVC() {
        if ListsUser.loggedIn {
            viewControllers[0].performSegue(withIdentifier: "LoginToListSkip", sender: self)
        }
    }
}
