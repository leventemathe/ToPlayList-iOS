//
//  User.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FirebaseAuth

enum UserResult {
    case succes
    case failure(UserError)
}

enum UserError {
    case usernameAlreadyInUse
    case unknownError
}

struct User {
    
    static let instance = User()
    
    private init() {}
    
    func createUser(_ onComplete: @escaping (UserResult)->(), withUsername username: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let providerid = FIRAuth.auth()?.currentUser?.providerID else {
            //TODO handle error
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let values: [String: Any] = ["username": username, "timestamp": timestamp, "provider": providerid]
        /*
        LISTS_DB_USERS.child(uid).updateChildValues(values) { (error, ref) in
            List.instance.createToPlayList { listID in
                LISTS_DB_USERS.child(uid).updateChildValues(["to_play_list_id": listID])
                List.instance.createPlayedList { listID in
                    LISTS_DB_USERS.child(uid).updateChildValues(["played_list_id": listID])
                    LISTS_DB_USERNAMES.child(username).updateChildValues(["userid": uid]) { (error, ref) in
                        if error != nil {
                            print(error.debugDescription)
                        } else {
                            onComplete()
                        }
                    }
                }
            }
        }
        */
        LISTS_DB_USERS.child(uid).updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error.debugDescription)
                onComplete(.failure(.usernameAlreadyInUse))
            } else {
                LISTS_DB_USERNAMES.child(username).updateChildValues(["userid": uid]) { (error, ref) in
                    if error != nil {
                        print(error.debugDescription)
                        onComplete(.failure(.unknownError))
                    } else {
                        onComplete(.succes)
                    }
                }

            }
        }

    }
    
    static var loggedIn: Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
}
