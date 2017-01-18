//
//  ListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FirebaseAuth

class ListVC: UIViewController, IdentifiableVC {
    

    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        
        // TODO are you sure you want to log out
        
        do {
            try FIRAuth.auth()?.signOut()
            _ = navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            // TODO error handling
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
}
