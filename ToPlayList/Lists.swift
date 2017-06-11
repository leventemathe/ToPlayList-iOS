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
import FirebaseDatabase

enum ListsUserResult {
    case success
    case failure(ListsUserError)
}

enum ListsUserError {
    case usernameAlreadyInUse
    case unknownError
}

class ListsUser {
    
    static let instance = ListsUser()
    
    private init() {}
    
    func createUserFromAuthenticated(_ onComplete: @escaping (ListsUserResult)->(), withUsername username: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let providerid = FIRAuth.auth()?.currentUser?.providerID else {
            onComplete(.failure(.unknownError))
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let userValues: [String: Any] = [ListsEndpoints.User.USERNAME: username, ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.User.PROVIDER: providerid]
        
        ListsEndpoints.USERS.child(uid).updateChildValues(userValues) { (error, ref) in
            if error != nil {
                onComplete(.failure(.usernameAlreadyInUse))
                return
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
                        return
                    }
                    onComplete(.success)
                    return
                })
            }
        }
    }
    
    func removeUser(_ uid: String, withOnComplete onComplete: @escaping ()->()) {
        ListsEndpoints.USERS.child(uid).removeValue { (error, ref) in
            onComplete()
        }
    }
    
    func removeUsername(_ username: String, withOnComplete onComplete: @escaping ()->()) {
        ListsEndpoints.USERNAMES.child(username).removeValue { (error, ref) in
            onComplete()
        }
    }
    
    func removeLists(_ uid: String, withOnComplete onComplete: @escaping ()->()) {
        var listIDs = [String]()
        
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            if let values = snapshot.value as? [String: Any] {
                for value in values {
                    if let list = value.value as? [String: Any], let listUid = list[ListsEndpoints.List.USERID] as? String {
                        if listUid == uid {
                            listIDs.append(value.key)
                        }
                    }
                }
                let listValues = self.buildListIDDictionary(listIDs)
                ListsEndpoints.BASE.updateChildValues(listValues) { (error, ref) in
                    onComplete()
                }
            }
            })
    }
    
    private func buildListIDDictionary(_ listIDs: [String]) -> [String: Any] {
        var result = [String: Any]()
        for listID in listIDs {
            let appendString = "\(ListsEndpoints.List.LISTS)/\(listID)"
            // an ugly hack to avoid Any? to Any coerce warning, because Firebase wants Any
            result[appendString] = Optional<String>.none as Any
        }
        return result
    }
    
    func deleteLoggedInUserCompletely(_ userName: String, withOnComplete onComplete: @escaping ()->()) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        removeUser(uid) {
            self.removeUsername(userName) {
                self.removeLists(uid) {
                    FIRAuth.auth()?.currentUser?.delete { error in
                        // TODO what should i do here?
                    }
                    onComplete()
                }
            }
        }
    }
    
    func deleteLoggedInUserBeforeFullyCreated() {
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
    
    private var listenerHandle: FIRAuthStateDidChangeListenerHandle?
    
    func listenToLoggedInState(onChange: @escaping ((userid: String?, loggedIn: Bool))->()) {
        if let auth = FIRAuth.auth() {
            listenerHandle = auth.addStateDidChangeListener { (auth, user) in
                onChange((userid: user?.uid ?? nil, loggedIn: auth.currentUser != nil))
            }
        }
    }
    
    func stopListeningToLoggedInState() {
        if let handle = listenerHandle {
            if let auth = FIRAuth.auth() {
                auth.removeStateDidChangeListener(handle)
            }
        }
    }
}



enum ListsListResult<T> {
    case succes(T)
    case failure(ListsListError)
}

enum ListsListError {
    case userLoggedOut
    case failedGettingListID
    case unknownError
}

struct ListsList {
    
    static let instance = ListsList()
    
    private init() {}
    
    func createToPlayList(_ onComplete: @escaping (ListsListResult<String>)->()) {
        createList(onComplete, withType: ListsEndpoints.List.TO_PLAY_LIST)
    }
    
    func createPlayedList(_ onComplete: @escaping (ListsListResult<String>)->()) {
        createList(onComplete, withType: ListsEndpoints.List.PLAYED_LIST)
    }
    
    private func createList(_ onComplete: @escaping (ListsListResult<String>)->(), withType type: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            onComplete(.failure(.unknownError))
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let value: [String: Any] = [ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.List.TYPE: type, ListsEndpoints.List.USERID: uid]
        ListsEndpoints.LISTS.childByAutoId().updateChildValues(value) { (error, ref) in
            if error != nil {
                onComplete(.failure(.unknownError))
                return
            }
            onComplete(.succes(ref.key))
            return
        }
    }
    
    func addGameToToPlayList(_ onComplete: @escaping (ListsListResult<String>)->(), thisGame game: Game) {
        addGameToListDeleteFromOther(onComplete, thisGame: game, withType: ListsEndpoints.List.TO_PLAY_LIST)
    }
    
    func addGameToPlayedList(_ onComplete: @escaping (ListsListResult<String>)->(), thisGame game: Game) {
        addGameToListDeleteFromOther(onComplete, thisGame: game, withType: ListsEndpoints.List.PLAYED_LIST)
    }
    
    private func addGameToListDeleteFromOther(_ onComplete: @escaping (ListsListResult<String>)->(), thisGame game: Game, withType type: String) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }

        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let values = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknownError))
                return
            }
  
            let addType = type
            let deleteType = addType == ListsEndpoints.List.TO_PLAY_LIST ? ListsEndpoints.List.PLAYED_LIST : ListsEndpoints.List.TO_PLAY_LIST
            
            for value in values {
                if let list = value.value as? [String: Any], let listType = list[ListsEndpoints.List.TYPE] as? String {
                    
                    let listID = value.key
                    let listItemID = "\(game.provider)\(game.id)"
                    let timestamp = Date().timeIntervalSince1970
                    
                    if listType == addType {
                        let values: [String: Any] = [ListsEndpoints.Game.PROVIDER: game.provider, ListsEndpoints.Game.PROVIDER_ID: game.id, ListsEndpoints.Game.NAME: game.name, ListsEndpoints.Game.COVER_SMALL_URL: game.coverSmallURLAsString as Any, ListsEndpoints.Game.COVER_BIG_URL: game.coverBigURLAsString as Any, ListsEndpoints.Common.TIMESTAMP: timestamp]
                        
                        ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES).child(listItemID).updateChildValues(values, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                onComplete(.failure(.unknownError))
                                return
                            }
                            onComplete(.succes(""))
                            return
                        })
                    } else if listType == deleteType {
                        ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES).child(listItemID).removeValue()
                    }
                } else {
                    onComplete(.failure(.unknownError))
                    return
                }
            }
        })
    }
    
    func getToPlayList(_ onComplete: @escaping (ListsListResult<List>)->()) {
        getList(ListsEndpoints.List.TO_PLAY_LIST, withOnComplete: onComplete)
    }
    
    func getPlayedList(_ onComplete: @escaping (ListsListResult<List>)->()) {
        getList(ListsEndpoints.List.PLAYED_LIST, withOnComplete: onComplete)
    }
    
    func getList(_ type: String, withOnComplete onComplete: @escaping (ListsListResult<List>)->()) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.unknownError))
            return
        }
        
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let lists = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknownError))
                return
            }
            
            for list in lists {
                if let list = list.value as? [String: Any], let listUID = list[ListsEndpoints.List.USERID] as? String {
                    if !self.isListOfType(list, isType: type) {
                        continue
                    }
                    if listUID != String(uid) {
                        onComplete(.failure(.unknownError))
                        return
                    }
                    
                    let result = self.deserializeGames(type, fromList: list)
                    if result != nil {
                        onComplete(.succes(result!))
                        return
                    } else {
                        onComplete(.failure(.unknownError))
                        return
                    }
                } else {
                    onComplete(.failure(.unknownError))
                    return
                }
            }
        })
    }
    
    func getToPlayListID(onComplete: @escaping (ListsListResult<String>)->()) {
        getListID(ListsEndpoints.List.TO_PLAY_LIST, withOnComplete: onComplete)
    }
    
    func getPlayedListID(onComplete: @escaping (ListsListResult<String>)->()) {
        getListID(ListsEndpoints.List.PLAYED_LIST, withOnComplete: onComplete)
    }
    
    func getListID(_ type: String, withOnComplete onComplete: @escaping (ListsListResult<String>)->()) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.unknownError))
            return
        }
        
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            if let lists = snapshot.value as? [String: Any] {
                for (key, value) in lists {
                    if let value = value as? [String: Any], let valueType = value[ListsEndpoints.List.TYPE] as? String, let valueUid = value[ListsEndpoints.List.USERID] as? String {
                        if valueType == type && valueUid == uid {
                            let listID = key
                            onComplete(.succes(listID))
                            return
                        }
                    } else {
                        onComplete(.failure(.unknownError))
                        return
                    }
                }
            } else {
                onComplete(.failure(.unknownError))
                return
            }
        })
    }
    
    private func isListOfType(_ list: [String: Any], isType type: String) -> Bool {
        if let listType = list[ListsEndpoints.List.TYPE] as? String {
            if listType != type {
                return false
            }
        }
        return true
    }
    
    private func deserializeGames(_ type: String, fromList list: [String: Any]) -> List? {
        let result = List(type)
        if let games = list[ListsEndpoints.List.GAMES] as? [String: Any] {
            for game in games {
                if let game = game.value as? [String: Any], let providerID = game[ListsEndpoints.Game.PROVIDER_ID] as? UInt64, let provider = game[ListsEndpoints.Game.PROVIDER] as? String, let name = game[ListsEndpoints.Game.NAME] as? String {
                    
                    let gameObj = Game(providerID, withName: name, withProvider: provider)
                    if let coverSmallURL = game[ListsEndpoints.Game.COVER_SMALL_URL] as? String {
                        gameObj.coverSmallURL = URL(string: coverSmallURL)
                    }
                    if let coverBigURL = game[ListsEndpoints.Game.COVER_BIG_URL] as? String {
                        gameObj.coverBigURL = URL(string: coverBigURL)
                    }
                    _ = result.add(gameObj)
                } else {
                    return nil
                }
            }
        }
        return result
    }
    
    typealias CombinedLists = (toPlay: List, played: List)
    
    func getToPlayAndPlayedList(_ onComplete: @escaping (ListsListResult<CombinedLists>)->()) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.unknownError))
            return
        }
        
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let lists = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknownError))
                return
            }

            var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST)
            var playedList = List(ListsEndpoints.List.PLAYED_LIST)
            for list in lists {
                if let list = list.value as? [String: Any], let listUID = list[ListsEndpoints.List.USERID] as? String {
                    if listUID != String(uid) {
                        onComplete(.failure(.unknownError))
                        return
                    }
                    
                    if self.isListOfType(list, isType: ListsEndpoints.List.TO_PLAY_LIST) {
                        let games = self.deserializeGames(ListsEndpoints.List.TO_PLAY_LIST, fromList: list)
                        if games == nil {
                            onComplete(.failure(.unknownError))
                            return
                        }
                        toPlayList = games!
                    }
                    if self.isListOfType(list, isType: ListsEndpoints.List.PLAYED_LIST) {
                        let games = self.deserializeGames(ListsEndpoints.List.PLAYED_LIST, fromList: list)
                        if games == nil {
                            onComplete(.failure(.unknownError))
                            return
                        }
                        playedList = games!
                    }
                } else {
                    onComplete(.failure(.unknownError))
                    return
                }
            }
            onComplete(.succes((toPlay: toPlayList, played: playedList)))
            return
        })
    }
    
    func removeGameFromToPlayList(_ game: Game, withOnComplete onComplete: @escaping (ListsListResult<String>)->()) {
        removeGameFromList(onComplete, thisGame: game, withType: ListsEndpoints.List.TO_PLAY_LIST)
    }
    
    func removeGameFromPlayedList(_ game: Game, withOnComplete onComplete: @escaping (ListsListResult<String>)->()) {
        removeGameFromList(onComplete, thisGame: game, withType: ListsEndpoints.List.PLAYED_LIST)
    }
    
    func removeGameFromList(_ onComplete: @escaping (ListsListResult<String>)->(), thisGame game: Game, withType type: String) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }
        
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let values = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknownError))
                return
            }
            
            for value in values {
                if let list = value.value as? [String: Any], let listType = list[ListsEndpoints.List.TYPE] as? String {
                    if listType == type {
                        let listID = value.key
                        let listItemID = "\(game.provider)\(game.id)"
                        ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES).child(listItemID).removeValue()
                        onComplete(.succes(""))
                        return
                    }
                }
            }
            onComplete(.failure(.unknownError))
            return
        })
    }
    
    func removeGameFromToPlayAndPlayedList(_ onComplete: @escaping (ListsListResult<String>)->(), thisGame game: Game) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }
        
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let values = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknownError))
                return
            }
            
            for value in values {
                if let list = value.value as? [String: Any], let listType = list[ListsEndpoints.List.TYPE] as? String {
                    if listType == ListsEndpoints.List.TO_PLAY_LIST {
                        let listID = value.key
                        let listItemID = "\(game.provider)\(game.id)"
                        ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES).child(listItemID).removeValue()
                    }
                    if listType == ListsEndpoints.List.PLAYED_LIST {
                        let listID = value.key
                        let listItemID = "\(game.provider)\(game.id)"
                        ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES).child(listItemID).removeValue()
                    }
                } else {
                    onComplete(.failure(.unknownError))
                    return
                }
            }
            onComplete(.succes(""))
            return
        })
    }
    
    func listenToToplayListAdd(_ listenerAttached: @escaping (ListsListResult<ListsListenerReference>)->(), withOnChange onChange: @escaping (ListsListResult<Game>)->()) {
        listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .add, withListenerAttached: listenerAttached, withOnChange: onChange)
    }
    
    func listenToPlayedListAdd(_ listenerAttached: @escaping (ListsListResult<ListsListenerReference>)->(), withOnChange onChange: @escaping (ListsListResult<Game>)->()) {
        listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .add, withListenerAttached: listenerAttached, withOnChange: onChange)
    }
    
    func listenToToplayListRemove(_ listenerAttached: @escaping (ListsListResult<ListsListenerReference>)->(), withOnChange onChange: @escaping (ListsListResult<Game>)->()) {
        listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .remove, withListenerAttached: listenerAttached, withOnChange: onChange)
    }
    
    func listenToPlayedListRemove(_ listenerAttached: @escaping (ListsListResult<ListsListenerReference>)->(), withOnChange onChange: @escaping (ListsListResult<Game>)->()) {
        listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .remove, withListenerAttached: listenerAttached, withOnChange: onChange)
    }
    
    // Get list id then call method that attaches observer
    func listenToList(_ type: String, withAction action: ListsListenerAction, withListenerAttached listenerAttached: @escaping (ListsListResult<ListsListenerReference>)->(), withOnChange onChange: @escaping (ListsListResult<Game>)->()) {
        getListID(type, withOnComplete: { result in
            switch result {
            case .failure(let error):
                switch error {
                default:
                    listenerAttached(.failure(.failedGettingListID))
                }
            case .succes(let id):
                self.listenToList(listenerAttached, withListID: id, withAction: action, withOnChange: onChange)
            }
        })
    }
    
    // Attaches the observer, after list id was found
    private func listenToList(_ listenerAttached: @escaping (ListsListResult<ListsListenerReference>)->(), withListID listID: String, withAction action: ListsListenerAction, withOnChange onChange: @escaping (ListsListResult<Game>)->()) {
        let ref = ListsEndpoints.LISTS.child(listID).child(ListsEndpoints.List.GAMES)
        let handle = ref.observe(getEventType(action), with: { snapshot in
            if let game = snapshot.value as? [String: Any], let gameID = game[ListsEndpoints.Game.PROVIDER_ID] as? UInt64, let gameName = game[ListsEndpoints.Game.NAME] as? String, let gameProvider = game[ListsEndpoints.Game.PROVIDER] as? String {
                let gameObj = Game(gameID, withName: gameName, withProvider: gameProvider)
                onChange(.succes(gameObj))
            } else {
                onChange(.failure(.unknownError))
            }
        })
        listenerAttached(.succes(ListsListenerReference(handle, forReference: ref)))
    }
    
    private func getEventType(_ action: ListsListenerAction) -> FIRDataEventType {
        switch action {
        case .add:
            return .childAdded
        case .remove:
            return .childRemoved
        }
    }
}

enum ListsListenerAction {
    case add
    case remove
}

struct ListsListenerReference {
    
    private let handle: FIRDatabaseHandle
    private let reference: FIRDatabaseReference
    
    func removeListener() {
        reference.removeObserver(withHandle: handle)
    }
    
    init(_ handle: FIRDatabaseHandle, forReference reference: FIRDatabaseReference) {
        self.handle = handle
        self.reference = reference
    }
}

