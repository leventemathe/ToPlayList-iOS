//
//  User.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    
    static var loggedIn: Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
}
