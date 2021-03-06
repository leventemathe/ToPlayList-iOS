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
    case permissionDenied
    case unknown
}

class ListsConnection {
    
    static func attachListenerForConnection(_ onChange: @escaping (Bool)->()) ->ListsListenerReference {
        let handle = ListsEndpoints.CONNECITON.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                onChange(true)
            } else {
                onChange(false)
            }
        })
        return ListsListenerReference(handle, forReference: ListsEndpoints.CONNECITON);
    }
}

class ListsUser {
    
    static let instance = ListsUser()
    
    private init() {}
    
    func createUserFromAuthenticated(_ onComplete: @escaping (ListsUserResult)->(), withUsername username: String) {
        guard let uid = Auth.auth().currentUser?.uid, let providerid = Auth.auth().currentUser?.providerID else {
            onComplete(.failure(.unknown))
            return
        }
        
        // if a forbidden char appears in a key on firebase, it crashes the app
        // so a validation rule on firebase is not enough
        for forbiddenChar in RegisterService.USERNAME_FORBIDDEN_CHARACTERS {
            if username.contains(forbiddenChar) {
                onComplete(.failure(.permissionDenied))
                return
            }
        }
        
        let timestamp = Date().timeIntervalSince1970
        let userValues: [String: Any] = [ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.User.USERNAME: username, ListsEndpoints.User.PROVIDER: providerid]
        let usernameValues: [String: Any] = [ListsEndpoints.Common.TIMESTAMP: timestamp, ListsEndpoints.Username.UID: uid]
        
        ListsEndpoints.USERS.child(uid).updateChildValues(userValues, withCompletionBlock: { (error, ref) in
            if error != nil {
                onComplete(.failure(.usernameAlreadyInUse))
                return
            } else {
                ListsEndpoints.USERNAMES.child(username).updateChildValues(usernameValues, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        onComplete(.failure(.usernameAlreadyInUse))
                        return
                    } else {
                        onComplete(.success)
                    }
                })
            }
        })
    }
    
    func createListsForUser(_ uid: String, withOnComplete onComplete: @escaping (ListsUserResult)->()) {
        let timestamp = Date().timeIntervalSince1970
        
        let toPlayListValues: [String: Any] = [ListsEndpoints.Common.TIMESTAMP: timestamp]
        let playedListValues: [String: Any] = [ListsEndpoints.Common.TIMESTAMP: timestamp]
        
        let values: [String: Any] = ["\(ListsEndpoints.List.LISTS)/\(uid)/\(ListsEndpoints.List.TO_PLAY_LIST)": toPlayListValues,
                                     "\(ListsEndpoints.List.LISTS)/\(uid)/\(ListsEndpoints.List.PLAYED_LIST)": playedListValues]
        
        ListsEndpoints.BASE.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                onComplete(.failure(.permissionDenied))
                return
            }
            onComplete(.success)
            return
        })
    }
    
    func removeUser(_ uid: String, withOnComplete onComplete: @escaping ()->()) {
        ListsEndpoints.USERS.child(uid).removeValue { (error, ref) in
            if error != nil {
                //print("Error while removing user: \(error.debugDescription)")
            }
            onComplete()
        }
    }
    
    func removeUsername(_ username: String, withOnComplete onComplete: @escaping ()->()) {
        ListsEndpoints.USERNAMES.child(username).removeValue { (error, ref) in
            if error != nil {
                //print("Error while removing user: \(error.debugDescription)")
            }
            onComplete()
        }
    }
    
    func removeLists(_ uid: String, withOnComplete onComplete: @escaping ()->()) {
        ListsEndpoints.LISTS.child(uid).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                //print("Error while removing user: \(error.debugDescription)")
            }
            onComplete()
        })
    }
    
    func deleteLoggedInUserCompletely(_ userName: String, withOnComplete onComplete: @escaping ()->()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        removeUsername(userName) {
            //print("removed username")
            self.removeUser(uid) {
                //print("removed user")
                self.removeLists(uid) {
                    //print("removed user lists")
                    Auth.auth().currentUser?.delete { error in
                        if error != nil {
                            //print("An error happened while trying to delete user: \(error.debugDescription)")
                        }
                        //print("removed user auth")
                        onComplete()
                    }
                }
            }
        }
    }
    
    func deleteLoggedInUserBeforeFullyCreated() {
        Auth.auth().currentUser?.delete { error in
            // TODO what should i do here?
        }
    }
    
    static var loggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    static var verified: Bool {
        if let verified = Auth.auth().currentUser?.isEmailVerified {
            return verified
        }
        return false
    }
    
    static var userid: String? {
        if let uid = Auth.auth().currentUser?.uid {
            return uid
        }
        return nil
    }
    
    static func getToken(_ onComplete: @escaping (String?)->()) {
        guard let user = Auth.auth().currentUser else {
            onComplete(nil)
            return
        }
        user.getIDToken(completion: { (token, error) in
            if error != nil {
                onComplete(nil)
            } else {
                if let token = token {
                    onComplete(token)
                } else {
                    onComplete(nil)
                }
            }
        })
    }
}



enum ListsListResult<T> {
    case success(T)
    case failure(ListsListError)
}

enum ListsListError {
    case userLoggedOut
    case failedGettingListID
    case unknown
}

struct ListsList {
    
    static let instance = ListsList()
    
    private init() {}
    
    func getKeyFrom(game: Game) -> String {
        return "\(game.provider)\(game.id)"
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
        if !(type == ListsEndpoints.List.TO_PLAY_LIST || type == ListsEndpoints.List.PLAYED_LIST) {
            onComplete(.failure(.unknown))
            return
        }
        let addType = type == ListsEndpoints.List.TO_PLAY_LIST ? ListsEndpoints.List.TO_PLAY_LIST : ListsEndpoints.List.PLAYED_LIST
        let removeType = addType == ListsEndpoints.List.TO_PLAY_LIST ? ListsEndpoints.List.PLAYED_LIST : ListsEndpoints.List.TO_PLAY_LIST
        
        var done = (add: false, remove: false)
        var errors: (add: ListsListError?, remove: ListsListError?)  = (add: nil, remove: nil)
        
        let timestamp = Date().timeIntervalSince1970
        let covers = self.getCovers(game)
        let values: [String: Any] = [ListsEndpoints.Game.PROVIDER: game.provider, ListsEndpoints.Game.PROVIDER_ID: game.id, ListsEndpoints.Game.NAME: game.name, ListsEndpoints.Game.COVER_SMALL_URL: covers.small as Any, ListsEndpoints.Game.COVER_BIG_URL: covers.big as Any, ListsEndpoints.Game.FIRST_RELEASE_DATE: game.firstReleaseDate as Any, ListsEndpoints.Common.TIMESTAMP: timestamp]
        
        ListsEndpoints.LISTS.child(uid).child(addType).child(ListsEndpoints.List.GAMES).child(getKeyFrom(game: game)).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                errors.add = .unknown
            }
            done.add = true
            if done.remove {
                if let error = errors.add {
                    onComplete(.failure(error))
                } else if let error = errors.remove {
                    onComplete(.failure(error))
                } else {
                    onComplete(.success(""))
                }
            }
        })
        
        ListsEndpoints.LISTS.child(uid).child(removeType).child(ListsEndpoints.List.GAMES).child(getKeyFrom(game: game)).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                errors.remove = .unknown
            }
            done.remove = true
            if done.add {
                if let error = errors.remove {
                    onComplete(.failure(error))
                } else if let error = errors.add {
                    onComplete(.failure(error))
                } else {
                    onComplete(.success(""))
                }
            }
        })
    }
    
    private func getCovers(_ game: Game) -> (small: String?, big: String?) {
        var result: (small: String?, big: String?)
        
        if game.coverSmallURLAsString != nil {
            result.small = game.coverSmallURLAsString
        } else if game.screenshotSmallURLAsString != nil {
            result.small = game.screenshotSmallURLAsString
        }
        
        if game.coverBigURLAsString != nil {
            result.big = game.coverBigURLAsString
        } else if game.screenshotBigURLAsString != nil {
            result.big = game.screenshotBigURLAsString
        }
        
        return result
    }
    
    func getToPlayList(_ onComplete: @escaping (ListsListResult<List>)->()) {
        getList(ListsEndpoints.List.TO_PLAY_LIST, withOnComplete: onComplete)
    }
    
    func getPlayedList(_ onComplete: @escaping (ListsListResult<List>)->()) {
        getList(ListsEndpoints.List.PLAYED_LIST, withOnComplete: onComplete)
    }
    
    func getList(_ type: String, withOnComplete onComplete: @escaping (ListsListResult<List>)->()) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }
        if !(type == ListsEndpoints.List.TO_PLAY_LIST || type == ListsEndpoints.List.PLAYED_LIST) {
            onComplete(.failure(.unknown))
            return
        }
        
        ListsEndpoints.LISTS.child(uid).child(type).observeSingleEvent(of: .value, with: { snapshot in
            guard let list = snapshot.value as? [String: Any] else {
                onComplete(.failure(.unknown))
                return
            }
            if let games = self.deserializeGames(type, fromList: list) {
                onComplete(.success(games))
                return
            } else {
                onComplete(.failure(.unknown))
                return
            }
        })
    }
    
    private func deserializeGames(_ type: String, fromList list: [String: Any]) -> List? {
        let result = List(type)
        if let games = list[ListsEndpoints.List.GAMES] as? [String: Any] {
            for game in games {
                if let game = game.value as? [String: Any], let providerID = game[ListsEndpoints.Game.PROVIDER_ID] as? UInt64, let provider = game[ListsEndpoints.Game.PROVIDER] as? String, let name = game[ListsEndpoints.Game.NAME] as? String {
                    let gameObject = deserializeGame(game, withProviderID: providerID, withName: name, withProvider: provider)
                    _ = result.add(gameObject)
                } else {
                    return nil
                }
            }
        }
        return result
    }
    
    private func deserializeGame(_ game: [String: Any], withProviderID providerID: UInt64, withName name: String, withProvider provider: String) -> Game {
        let gameObj = Game(providerID, withName: name, withProvider: provider)
        if let coverSmallURL = game[ListsEndpoints.Game.COVER_SMALL_URL] as? String {
            gameObj.coverSmallURL = URL(string: coverSmallURL)
        }
        if let coverBigURL = game[ListsEndpoints.Game.COVER_BIG_URL] as? String {
            gameObj.coverBigURL = URL(string: coverBigURL)
        }
        if let timestamp = game[ListsEndpoints.Common.TIMESTAMP] as? Double {
            gameObj.timestamp = timestamp
        }
        if let firstReleaseDate = game[ListsEndpoints.Game.FIRST_RELEASE_DATE] as? Double {
            gameObj.firstReleaseDate = firstReleaseDate
        }
        return gameObj
    }
    
    typealias CombinedLists = (toPlay: List, played: List)
    
    func getToPlayAndPlayedList(_ onComplete: @escaping (ListsListResult<CombinedLists>)->()) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }
        
        var done = (toPlay: false, played: false)
        var toPlay: List?
        var played: List?
        
        ListsEndpoints.LISTS.child(uid).child(ListsEndpoints.List.TO_PLAY_LIST).observeSingleEvent(of: .value, with: { snapshot in
            if let list = snapshot.value as? [String: Any], let games = self.deserializeGames(ListsEndpoints.List.TO_PLAY_LIST, fromList: list) {
                toPlay = games
            }
            done.toPlay = true
            if done.played {
                if toPlay == nil || played == nil {
                    onComplete(.failure(.unknown))
                } else {
                    onComplete(.success((toPlay: toPlay!, played: played!)))
                }
            }
        })
        
        ListsEndpoints.LISTS.child(uid).child(ListsEndpoints.List.PLAYED_LIST).observeSingleEvent(of: .value, with: { snapshot in
            if let list = snapshot.value as? [String: Any], let games = self.deserializeGames(ListsEndpoints.List.PLAYED_LIST, fromList: list) {
                played = games
            }
            done.played = true
            if done.toPlay {
                if toPlay == nil || played == nil {
                    onComplete(.failure(.unknown))
                } else {
                    onComplete(.success((toPlay: toPlay!, played: played!)))
                }
            }
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
        if !(type == ListsEndpoints.List.TO_PLAY_LIST || type == ListsEndpoints.List.PLAYED_LIST) {
            onComplete(.failure(.unknown))
            return
        }
        
        ListsEndpoints.LISTS.child(uid).child(type).child(ListsEndpoints.List.GAMES).child(getKeyFrom(game: game)).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                onComplete(.failure(.unknown))
            } else {
                onComplete(.success(""))
            }
        })
    }
    
    func removeGameFromToPlayAndPlayedList(_ onComplete: @escaping (ListsListResult<String>)->(), thisGame game: Game) {
        guard let uid = ListsUser.userid else {
            onComplete(.failure(.userLoggedOut))
            return
        }
        
        let values: [String: Any] = ["\(ListsEndpoints.List.TO_PLAY_LIST)/\(ListsEndpoints.List.GAMES)/\(getKeyFrom(game: game))": Optional<String>.none as Any,
                                     "\(ListsEndpoints.List.PLAYED_LIST)/\(ListsEndpoints.List.GAMES)/\(getKeyFrom(game: game))": Optional<String>.none as Any]
        
        ListsEndpoints.LISTS.child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                onComplete(.failure(.unknown))
            } else {
                onComplete(.success(""))
            }
        })
    }
    
    func listenToToplayListAdd(_ onChange: @escaping (ListsListResult<Game>)->()) -> ListsListResult<ListsListenerReference> {
        return listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .add, withOnChange: onChange)
    }
    
    func listenToPlayedListAdd(_ onChange: @escaping (ListsListResult<Game>)->()) -> ListsListResult<ListsListenerReference> {
        return listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .add, withOnChange: onChange)
    }
    
    func listenToToplayListRemove(_ onChange: @escaping (ListsListResult<Game>)->()) -> ListsListResult<ListsListenerReference> {
        return listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .remove, withOnChange: onChange)
    }
    
    func listenToPlayedListRemove(_ onChange: @escaping (ListsListResult<Game>)->()) -> ListsListResult<ListsListenerReference> {
        return listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .remove, withOnChange: onChange)
    }
    
    func listenToList(_ type: String, withAction action: ListsListenerAction, withOnChange onChange: @escaping (ListsListResult<Game>)->()) -> ListsListResult<ListsListenerReference> {
        guard let uid = ListsUser.userid else {
            return .failure(.userLoggedOut)
        }
        if !(type == ListsEndpoints.List.TO_PLAY_LIST || type == ListsEndpoints.List.PLAYED_LIST) {
            return .failure(.unknown)
        }
        
        let ref = ListsEndpoints.LISTS.child(uid).child(type).child(ListsEndpoints.List.GAMES)
        let handle = ref.observe(getEventType(action), with: { snapshot in
            if let game = snapshot.value as? [String: Any], let providerID = game[ListsEndpoints.Game.PROVIDER_ID] as? UInt64, let gameName = game[ListsEndpoints.Game.NAME] as? String, let gameProvider = game[ListsEndpoints.Game.PROVIDER] as? String {
                let gameObj = self.deserializeGame(game, withProviderID: providerID, withName: gameName, withProvider: gameProvider)
                onChange(.success(gameObj))
            } else {
                onChange(.failure(.unknown))
            }
        })
        return .success(ListsListenerReference(handle, forReference: ref))
    }
    
    private func getEventType(_ action: ListsListenerAction) -> DataEventType {
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
    
    private let handle: DatabaseHandle
    private let reference: DatabaseReference
    
    func removeListener() {
        reference.removeObserver(withHandle: handle)
    }
    
    init(_ handle: DatabaseHandle, forReference reference: DatabaseReference) {
        self.handle = handle
        self.reference = reference
    }
}

