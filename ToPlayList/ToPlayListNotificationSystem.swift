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

class ToPlayListNotificationSystem: NSObject, UNUserNotificationCenterDelegate {
    
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
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    
    var permissionGranted = false
    
    private override init() {
        super.init()
        print("notification system initialized")
        UNUserNotificationCenter.current().delegate = self
        requestPermission()
    }
    
    deinit {
        print("notification system deinitialized")
        removeListeners()
    }
    
    
    
    // Listeners
    
    func attachListeners() {
        print("attaching listeners")
        removeLateToPlayListListenerAdd()
        removeLatePlayedListListenerRemove()
        listenToToPlayList(.add, withOnChange: { game in
            print("add listener fired for \(game.name)")
            self.addNotification(forGame: game)
        })
        listenToToPlayList(.remove, withOnChange: { game in
            print("remove listener fired for \(game.name)")
            self.removeNotification(forGame: game)
        })
    }
    
    private func listenToToPlayList(_ action: ListsListenerAction, withOnChange onChange: @escaping (Game)->()) {
        ListsList.instance.listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: action, withListenerAttached: { result in
            switch result {
            case .succes(let ref):
                self.listListenerAttachmentSuccesful(action, forReference: ref)
            case .failure(let error):
                switch error {
                default:
                    print("An error occured while trying to attach listeners for notifications: \(error)")
                }
            }
        }, withOnChange: { result in
            switch result {
            case .succes(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    print("An error occured while trying to attach listeners for notifications: \(error)")
                }
            }
        })
    }
    
    private func listListenerAttachmentSuccesful(_ action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            self.toPlayListListenerAdd = ref
        case .remove:
            self.toPlayListListenerRemove = ref
        }
    }
    
    private func removeLateToPlayListListenerAdd() {
        if shouldRemoveToPlayListListenerAdd > 0 {
            toPlayListListenerAdd?.removeListener()
            toPlayListListenerAdd = nil
            shouldRemoveToPlayListListenerAdd -= 1
        }
    }
    
    private func removeLatePlayedListListenerRemove() {
        if shouldRemoveToPlayListListenerRemove > 0 {
            toPlayListListenerRemove?.removeListener()
            toPlayListListenerRemove = nil
            shouldRemoveToPlayListListenerRemove -= 1
        }
    }
    
    func removeListeners() {
        print("removing listeners")
        removeToPlayListListenerAdd()
        removeToPlayListListenerRemove()
    }
    
    private func removeToPlayListListenerAdd() {
        if toPlayListListenerAdd != nil {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
        } else {
            shouldRemoveToPlayListListenerAdd += 1
        }
    }
    
    private func removeToPlayListListenerRemove() {
        if toPlayListListenerRemove != nil {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
        } else {
            shouldRemoveToPlayListListenerRemove += 1
        }
    }
    
    
    
    // Notifications
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,], completionHandler: { (granted, error) in
            print("Called request auth with result: \(granted)")
            if granted {
                self.permissionGranted = true
                self.attachListeners()
            }
        })
    }
    
    private func addNotification(forGame game: Game) {
        // if the game has been released already, there's no need for a notification
        print("add notif hasn't passed date test yet")
        if game.firstReleaseDate == nil || game.firstReleaseDate! < Dates.dateForNewestReleases() {
            return
        }
        print("add notif passed date test")
        
        let content = buildContent(forGame: game)
        let trigger = buildNotificationTrigger(forGame: game)
        let request = UNNotificationRequest(identifier: "\(game.name)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("An error happened while request notification permission: \(error!.localizedDescription)")
            } else {
                print("---------Notifications after adding----------")
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { $0.forEach({ print($0.identifier) }) })
            }
        })
    }
    
    private func buildContent(forGame game: Game) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Fun times!"
        content.body = "A game on your ToPlay list (\(game.name)) is released today."
        content.sound = UNNotificationSound.default()
        return content
    }
    
    private func buildNotificationTrigger(forGame game: Game) -> UNCalendarNotificationTrigger {
        //let releaseDate = Date(timeIntervalSince1970: game.firstReleaseDate!)
        let releaseDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 10)
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: releaseDate)
        //let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour], from: releaseDate)
        return UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
    }
    
    func removeNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func removeNotification(forGame game: Game) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [game.name])
        print("---------Notifications after removing----------")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { $0.forEach({ print($0.identifier) }) })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // TODO
    }
}
