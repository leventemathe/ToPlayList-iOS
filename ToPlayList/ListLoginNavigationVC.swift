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
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        var vc: UIViewController
        if User.loggedIn {
            vc = storyBoard.instantiateViewController(withIdentifier: ListVC.id)
        } else {
            vc = storyBoard.instantiateViewController(withIdentifier: LoginVC.id)
        }
        setViewControllers([vc], animated: false)
    }
}
