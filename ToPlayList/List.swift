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
        let userValues: [String: Any] = [ListsEndpoints.User.USERNAME: username, ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.User.PROVIDER: providerid]
        
        ListsEndpoints.USERS.child(uid).updateChildValues(userValues) { (error, ref) in
            if error != nil {
                onComplete(.failure(.usernameAlreadyInUse))
            } else {
                let toPlayListID = ListsEndpoints.LISTS.childByAutoId().key
                let playedListID = ListsEndpoints.LISTS.childByAutoId().key
                
                let userValues = [toPlayListID, playedListID]
                let usernameValues: [String: Any] = [ListsEndpoints.Username.USERID: uid, ListsEndpoints.Common.TIMESTAMP: timestamp]
                let toPlayListValues: [String: Any] = [ListsEndpoints.List.TYPE: ListsEndpoints.List.TO_PLAY_LIST, ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.List.USERID: uid]
                let playedListValues: [String: Any] = [ListsEndpoints.List.TYPE: ListsEndpoints.List.PLAYED_LIST, ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.List.USERID: uid]
                
                let values: [String: Any] = ["\(ListsEndpoints.User.USERS)/\(uid)/\(ListsEndpoints.List.LISTS)": userValues,
                    "\(ListsEndpoints.Username.USERNAMES)/\(username)": usernameValues,
                    "\(ListsEndpoints.List.LISTS)/\(toPlayListID)": toPlayListValues,
                    "\(ListsEndpoints.List.LISTS)/\(playedListID)": playedListValues]
                
                ListsEndpoints.BASE.updateChildValues(values, withCompletionBlock: { (error, ref) in
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
    
    static var userid: String? {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            return uid
        }
        return nil
    }
}



enum ListsListResult {
    case succes
    case succesWithRef(String)
    case failure(ListsListError)
}

enum ListsListError {
    case userLoggedOut
    case unknownError
}

struct ListsList {
    
    static let instance = ListsList()
    
    private init() {}
    
    func createToPlayList(_ onComplete: @escaping (ListsListResult)->()) {
        createList(onComplete, withType: ListsEndpoints.List.TO_PLAY_LIST)
    }
    
    func createPlayedList(_ onComplete: @escaping (ListsListResult)->()) {
        createList(onComplete, withType: ListsEndpoints.List.PLAYED_LIST)
    }
    
    private func createList(_ onComplete: @escaping (ListsListResult)->(), withType type: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            onComplete(.failure(.unknownError))
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let value: [String: Any] = [ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.List.TYPE: type, ListsEndpoints.List.USERID: uid]
        ListsEndpoints.LISTS.childByAutoId().updateChildValues(value) { (error, ref) in
            if error != nil {
                onComplete(.failure(.unknownError))
            }
            onComplete(.succesWithRef(ref.key))
        }
    }
    
    func addGameToToPlayList(_ onComplete: @escaping (ListsListResult)->(), thisGame game: Game) {
        addGameToListDeleteFromOther(onComplete, thisGame: game, withType: ListsEndpoints.List.TO_PLAY_LIST)
    }
    
    func addGameToPlayedList(_ onComplete: @escaping (ListsListResult)->(), thisGame game: Game) {
        addGameToListDeleteFromOther(onComplete, thisGame: game, withType: ListsEndpoints.List.PLAYED_LIST)
    }
    
    private func addGameToListDeleteFromOther(_ onComplete: @escaping (ListsListResult)->(), thisGame game: Game, withType type: String) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }

        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let values = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknownError))
                return
            }
            
            //var addListID: String?
            //var deleteListID: String?
            
            for value in values {
                if let list = value.value as? [String: Any], let listType = list[ListsEndpoints.List.TYPE] as? String {
                    /*
                    let listID = value.key
                    if listType == type {
                        addListID = listID
                    } else {
                        // TODO exclusive list data type
                    }
                    */
                    
                    
                    if listType == type {
                        
                        let listID = value.key
                        let timestamp = Date().timeIntervalSince1970
                        let values: [String: Any] = [ListsEndpoints.Game.PROVIDER: game.provider, ListsEndpoints.Game.PROVIDER_ID: game.id, ListsEndpoints.Common.TIMESTAMP: timestamp]
                        let listItemID = "\(game.provider)\(game.id)"
                        
                        ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES).child(listItemID).updateChildValues(values, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                onComplete(.failure(.unknownError))
                            }
                            onComplete(.succes)
                        })
                        
                        break
                    }
                }
            }
        })
        
        
    }
}

