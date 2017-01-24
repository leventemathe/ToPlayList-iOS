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
    
    static let instance = User()
    
    private init() {}
    
    func createUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //TODO handle error
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let values = ["timestamp": timestamp]
        LISTS_DB_USERS.child(uid).updateChildValues(values) { (error, ref) in
            List.instance.createToPlayList { listID in
                LISTS_DB_USERS.child(uid).updateChildValues(["to_play_list": listID])            }
            List.instance.createPlayedList { listID in
                LISTS_DB_USERS.child(uid).updateChildValues(["played_list": listID])
            }
        }
    }
    
    static var loggedIn: Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
}
