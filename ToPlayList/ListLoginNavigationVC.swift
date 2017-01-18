//
//  ListLoginNavigationVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ListLoginNavigationVC: UINavigationController {
    
    override func viewWillAppear(_ animated: Bool) {
        if User.loggedIn {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let listVC = storyBoard.instantiateViewController(withIdentifier: ListVC.id)
            pushViewController(listVC, animated: animated)
        }
    }
}
