//
//  ToPlayList.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FirebaseAuth

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



struct ListsList {
    
    static let instance = ListsList()
    
    private init() {}
    
    func createToPlayList(_ onComplete: @escaping (String)->()) {
        createList(onComplete, withType: "to_play_list")
    }
    
    func createPlayedList(_ onComplete: @escaping (String)->()) {
        createList(onComplete, withType: "played_list")
    }
    
    private func createList(_ onComplete: @escaping (String)->(), withType type: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //TODO handle error
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let value: [String: Any] = ["timestamp": timestamp, "type": type, "userid": uid]
        LISTS_DB_LISTS.childByAutoId().updateChildValues(value) { (error, ref) in
            onComplete(ref.key)
        }
    }
    
    func addGameToToPlayList(_ game: Game) {
        print("added game to ToPlay List")
    }
    
    func addGameToPlayedList(_ game: Game) {
        print("added game to Played List")
    }
    
    private func addGameToList(_ game: Game, withType type: String) {
        
    }
}



struct ListsGame {
 
    static let instance = ListsGame()
    
    private init() {}
    
    func createGame(_ onComplete: @escaping ()->(), fromGame game: Game) {
        let timestamp = Date().timeIntervalSince1970
        var genre = ""
        var developer = ""
        if game.genre != nil {
            genre = game.genre!.name
        }
        if game.developer != nil {
            developer = game.developer!.name
        }
        let value: [String: Any] = ["timestamp": timestamp, "provider": game.provider, "providerID": game.id, "name": game.name, "genre": genre, "developer": developer]
        
        //TODO add the values to firbase
    }
}


