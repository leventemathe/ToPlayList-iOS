//
//  ListsNotificationSystem.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

protocol ToPlayListNotificationSystemDelegate: class {
    
    func toPlayListNotifictaionSystempermissionRequested(_ onComplete: @escaping ()->())
}

class ToPlayListNotificationSystem: NSObject, UNUserNotificationCenterDelegate {
    
    // SETUP AND TEARDOWN
    
    private static var _instance: ToPlayListNotificationSystem?
    static var instance: ToPlayListNotificationSystem? {
        get {
            return _instance
        }
    }
    
    // the system is initialized once, after the list has been downloaded
    // it uses the listeners after, to add/remove games
    // it's also a global singleton, so app delegate can easily reach it to attach/remove listeners as app closes/opens etc.
    
    static func setup() {
        if ToPlayListNotificationSystem._instance == nil {
            ToPlayListNotificationSystem._instance = ToPlayListNotificationSystem()
        }
    }
    
    static func teardown() {
        ToPlayListNotificationSystem._instance?.removeListeners()
        ToPlayListNotificationSystem._instance?.removeNotifications()
        ToPlayListNotificationSystem._instance = nil
    }
    
    var permissionGranted = false
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    deinit {
        removeListeners()
    }
    
    func listen() {
        attachListeners()
    }
    
    func unlisten() {
        removeListeners()
    }
    
    // DB LISTENERS
    
    private func attachListeners() {
        listenToToPlayList(.add, withOnChange: { game in
            //print("add listener fired for \(game.name)")
            self.addNotification(forGame: game)
        })
        listenToToPlayList(.remove, withOnChange: { game in
            //print("remove listener fired for \(game.name)")
            self.removeNotification(forGame: game)
        })
    }
    
    private func listenToToPlayList(_ action: ListsListenerAction, withOnChange onChange: @escaping (Game)->()) {
        let listeningResult = ListsList.instance.listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: action, withOnChange: { result in
            switch result {
            case .success(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    //print("An error occured while listening to db for notifications: \(error)")
                    break
                }
            }
        })
        
        switch listeningResult {
        case .success(let ref):
            self.listListenerAttachmentSuccesful(action, forReference: ref)
        case .failure(let error):
            switch error {
            default:
                //print("An error occured while trying to attach listeners for notifications: \(error)")
                break
            }
        }
    }
    
    private func listListenerAttachmentSuccesful(_ action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            self.toPlayListListenerAdd = ref
        case .remove:
            self.toPlayListListenerRemove = ref
        }
    }
    
    private func removeListeners() {
        removeToPlayListListenerAdd()
        removeToPlayListListenerRemove()
    }
    
    private func removeToPlayListListenerAdd() {
        toPlayListListenerAdd?.removeListener()
        toPlayListListenerAdd = nil
    }
    
    private func removeToPlayListListenerRemove() {
        toPlayListListenerRemove?.removeListener()
        toPlayListListenerRemove = nil
    }
    
    
    
    // SHCEDULING/UNSCHEDULING NOTIFICATIONS
    
    weak var delegate: ToPlayListNotificationSystemDelegate?
    
    private let HAS_PERMISSION_BEEN_ASKED_FOR = "permission_asked_for"
    
    func requestPermission() {
        if UserDefaults.standard.bool(forKey: HAS_PERMISSION_BEEN_ASKED_FOR) {
            sendPermissionRequest()
        } else {
            delegate?.toPlayListNotifictaionSystempermissionRequested {
                self.sendPermissionRequest()
            }
            UserDefaults.standard.set(true, forKey: HAS_PERMISSION_BEEN_ASKED_FOR)
        }
    }
    
    private func sendPermissionRequest() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,], completionHandler: { (granted, error) in
            //print("Called request auth with result: \(granted)")
            if granted {
                self.permissionGranted = true
                self.listen()
            }
        })
    }
    
    private func addNotification(forGame game: Game) {
        shouldAddNotif(forGame: game, withOnComplete: { shouldAdd in
            if shouldAdd {
                let content = self.buildContent(forGame: game)
                let trigger = self.buildNotificationTrigger(forGame: game)
                let request = UNNotificationRequest(identifier: "\(game.name)", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        //print("An error happened while request notification permission: \(error!.localizedDescription)")
                    }
                })
            } else {
                //print("Shouldn't add notif for \(game.name)")
            }
        })
    }
    
    private func shouldAddNotif(forGame game: Game, withOnComplete onComplete: @escaping (Bool)->()) {
        // if the game has been released already, there's no need for a notification
        if game.firstReleaseDate == nil || game.firstReleaseDate! < Dates.dateForNewestReleases() {
            onComplete(false)
            return
        }
        if !(ListsUser.loggedIn && ListsUser.verified) {
            onComplete(false)
            return
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifs in
            for notif in notifs {
                if let notifGame = notif.content.userInfo[ToPlayListNotificationSystem.USER_INFO_GAME_KEY] as? String {
                    if notifGame == game.name {
                        onComplete(false)
                        return
                    }
                }
            }
            onComplete(true)
        })
    }
    
    static let USER_INFO_GAME_KEY = "game"
    
    private func buildContent(forGame game: Game) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Fun time!"
        content.body = "A game on your ToPlay list (\(game.name)) is released today."
        content.sound = UNNotificationSound.default()
        content.userInfo = [ToPlayListNotificationSystem.USER_INFO_GAME_KEY: game.name]
        return content
    }
    
    private func buildNotificationTrigger(forGame game: Game) -> UNCalendarNotificationTrigger? {
        guard let releaseDate = game.firstReleaseDate else {
            return nil
        }
        let randomizedReleaseDate = Dates.randomHourOfDay(releaseDate)
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: randomizedReleaseDate)
        // for debugging: notif arrives in 8 seconds, release date doesn't matter
        //let debugReleaseDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 8)
        //let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: debugReleaseDate)
        return UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
    }
    
    func removeNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func removeNotification(forGame game: Game) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [game.name])
    }
    
    
    
    // NOTIFICATION ARRIVED/TAPPED LISTENERS
    
    private var notifArrivedObservers = [String: (String)->()]()
    private var notifTappedObservers = [String: (String)->()]()
    
    func addNotificationArrivedObserver(_ observer: @escaping (String)->(), withName name: String) {
        notifArrivedObservers[name] = observer
    }
    
    func addNotificationTappedObserver(_ observer: @escaping (String)->(), withName name: String) {
        notifTappedObservers[name] = observer
        if let game = AppDelegate.appLaunchedWithNotifTappedForThisGame {
            notifTappedObservers[name]!(game)
        }
    }
    
    func removeNotificationArrivedObserver(_ observer: @escaping (String)->(), withName name: String) {
        notifArrivedObservers[name] = nil
    }
    
    func removeNotificationTappedObserver(_ observer: (String)->(), withName name: String) {
        notifTappedObservers[name] = nil
    }
    
    // the notif appeared while the app is in the foreground -> add badge to lists tab bar item, add badge to released game list item in list vc
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let game = notification.request.content.userInfo[ToPlayListNotificationSystem.USER_INFO_GAME_KEY] as? String {
            notifyArrivedObservers(game)
        }
        
        // show notif banner and play sound
        let options: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(options)
    }
    
    // the notif was tapped (either when the is in background or foreground) -> add badge to released game list item in list vc, go to list vc, then to details
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let game = response.notification.request.content.userInfo[ToPlayListNotificationSystem.USER_INFO_GAME_KEY] as? String {
            notifyTappedObservers(game)
        }
        completionHandler()
    }
    
    private func notifyArrivedObservers(_ game: String) {
        notifArrivedObservers.forEach({ $0.value(game) })
    }
    
    private func notifyTappedObservers(_ game: String) {
        notifTappedObservers.forEach({ $0.value(game) })
    }
}





