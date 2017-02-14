//
//  ToPlayList.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

enum ListsUserResult {
    case succes
    case failure(ListsUserError)
}

enum ListsUserError {
    case usernameAlreadyInUse
    case unknownError
}

struct ListsUser {
    
    static let instance = ListsUser()
    
    private init() {}
    
    func createUser(_ onComplete: @escaping (ListsUserResult)->(), withUsername username: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let providerid = FIRAuth.auth()?.currentUser?.providerID else {
            onComplete(.failure(.unknownError))
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let userValues: [String: Any] = ["username": username, "timestamp": timestamp, "provider": providerid]
        
        LISTS_DB_USERS.child(uid).updateChildValues(userValues) { (error, ref) in
            if error != nil {
                print(error.debugDescription)
                onComplete(.failure(.usernameAlreadyInUse))
            } else {
                let usernameValues: [String: Any] = ["userid": uid, "timestamp": timestamp]
                let toPlayListValues: [String: Any] = ["type": "to_play_list", "timestamp": timestamp, "userid": uid]
                let playedListValues: [String: Any] = ["type": "played_list", "timestamp:": timestamp, "userid": uid]
                let toPlayListID = LISTS_DB_LISTS.childByAutoId().key
                let playedListID = LISTS_DB_LISTS.childByAutoId().key
                
                let values = ["usernames/\(username)": usernameValues, "lists/\(toPlayListID)": toPlayListValues, "lists/\(playedListID)": playedListValues]
                
                LISTS_DB_BASE.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        onComplete(.failure(.unknownError))
                    }
                    onComplete(.succes)
                })
            }
        }
    }
    
    func deleteUserBeforeFullyCreated() {
        FIRAuth.auth()?.currentUser?.delete { error in
            // TODO what should i do here?
        }
    }
    
    static var loggedIn: Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
}



enum ListsListResult {
    case succesWithRef(String)
    case failure(ListsListError)
}

enum ListsListError {
    case unknownError
}

struct ListsList {
    
    static let instance = ListsList()
    
    private init() {}
    
    func createToPlayList(_ onComplete: @escaping (ListsListResult)->()) {
        createList(onComplete, withType: "to_play_list")
    }
    
    func createPlayedList(_ onComplete: @escaping (ListsListResult)->()) {
        createList(onComplete, withType: "played_list")
    }
    
    private func createList(_ onComplete: @escaping (ListsListResult)->(), withType type: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            onComplete(.failure(.unknownError))
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let value: [String: Any] = ["timestamp": timestamp, "type": type, "userid": uid]
        LISTS_DB_LISTS.childByAutoId().updateChildValues(value) { (error, ref) in
            if error != nil {
                onComplete(.failure(.unknownError))
            }
            onComplete(.succesWithRef(ref.key))
        }
    }
    
    func addGameToToPlayList(_ game: Game) {
        print("added game to ToPlay List")
        addGameToList(game, withType: "to_play_list")
    }
    
    func addGameToPlayedList(_ game: Game) {
        print("added game to Played List")
        addGameToList(game, withType: "played_list")
    }
    
    private func addGameToList(_ game: Game, withType type: String) {
        //let provider = game.provider
        //let providerID = game.id
    }
}

