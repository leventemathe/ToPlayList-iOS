//
//  NewestNavigationVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class NewestNavigationVC: UINavigationController {
 
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newestVC = storyboard.instantiateViewController(withIdentifier: ReleasesVC.id) as! ReleasesVC

        addChildViewController(newestVC)
    }
}
