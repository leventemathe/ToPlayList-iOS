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

class ToPlayListNotificationSystem {
    
    private var toPlayList: List
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    
    private var permissionGranted = false
    
    init(_ toPlayList: List) {
        self.toPlayList = toPlayList
        print("notification system initialized")
        requestPermission()
        // TODO setup listeners
    }
    
    deinit {
        print("notification system deinitialized")
        // TODO remove listeners
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if granted {
                self.permissionGranted = true
                self.addNotifications()
            }
        })
    }
    
    private func addNotifications() {
        for game in toPlayList {
            addNotification(forGame: game)
        }
    }
    
    private func addNotification(forGame game: Game) {
        // if the game has been released already, there's no need for a notification
        if game.firstReleaseDate == nil || game.firstReleaseDate! < Dates.dateForNewestReleases() {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "A game on your ToPlayList has been released!"
        content.body = "(\(game.name) has been released today."
        // TODO
        content.badge = nil
        // TODO sound
        
        let trigger = buildNotificationTrigger(forGame: game)
        let request = UNNotificationRequest(identifier: "\(game.name) notification", content: content, trigger: trigger)
        
        print("---------Notifications alreay added----------")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { $0.forEach({ print($0.identifier) }) })
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("added \(game.name) notif request yay")
            }
        })
    }
    
    private func buildNotificationTrigger(forGame game: Game) -> UNCalendarNotificationTrigger {
        let releaseDate = Date(timeIntervalSince1970: game.firstReleaseDate!)
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: releaseDate)
        return UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
    }
}
