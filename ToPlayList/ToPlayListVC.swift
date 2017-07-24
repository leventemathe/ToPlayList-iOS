//
//  ToPlayListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import UserNotifications

class ToPlayListVC: SubListVC {
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST)
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReadyForNotifs()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getToPlayList {
            self.attachListeners()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeListeners()
    }
    
    private func attachListeners() {
        listenToToPlayList(.add, withOnChange: { game in
            if self.toPlayList.add(game) {
                self.setContent()
            }
        })
        listenToToPlayList(.remove, withOnChange: { game in
            self.toPlayList.remove(game)
            self.setContent()
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
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        }, withOnChange: { result in
            switch result {
            case .succes(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        })
    }
    
    private func listListenerAttachmentSuccesful(_ action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            self.toPlayListListenerAdd = ref
            self.removeLateToPlayListListenerAdd()
        case .remove:
            self.toPlayListListenerRemove = ref
            self.removeLatePlayedListListenerRemove()
        }
    }
    
    private func removeLateToPlayListListenerAdd() {
        if shouldRemoveToPlayListListenerAdd > 0 {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
            shouldRemoveToPlayListListenerAdd -= 1
        }
    }
    
    private func removeLatePlayedListListenerRemove() {
        if shouldRemoveToPlayListListenerRemove > 0 {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
            shouldRemoveToPlayListListenerRemove -= 1
        }
    }
    
    func removeListeners() {
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
    
    private func getToPlayList(_ onComplete: @escaping ()->()) {
        ListsList.instance.getToPlayList { result in
            self.loadingAnimationView.stopAnimating()
            self.appeared = true
            var shouldSetContent = true
            
            switch result {
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            case .succes(let list):
                if self.toPlayList == list {
                    shouldSetContent = false
                } else {
                    self.toPlayList = list
                }
            }
            if shouldSetContent {
                self.setContent()
                self.readyForNotifs.checks[ReadyForNotifications.GAMES_DOWNLOADED] = true
            }
            onComplete()
        }
    }
    
    private var listWasEmptyLastTime: Bool?
    
    private func setContent() {
        print("set content in toPlay list")
        collectionView.reloadData()
        if toPlayList.count < 1 {
            if listWasEmptyLastTime == nil || !listWasEmptyLastTime!{
                swapToListEmptyLabels()
            }
            listWasEmptyLastTime = true
        } else {
            if listWasEmptyLastTime == nil || listWasEmptyLastTime! {
                swapToCollectionView()
            }
            listWasEmptyLastTime = false
        }
    }
    
    class ReadyForNotifications {
        
        static let PERMISSION_GRANTED = "permission_granted"
        static let GAMES_DOWNLOADED = "games_downloaded"
        
        typealias AllReadyCallback = () -> ()
        
        var allReadyCallback: AllReadyCallback
        
        var checks = [PERMISSION_GRANTED: false, GAMES_DOWNLOADED: false] {
            didSet {
                if isAllDone() {
                    allReadyCallback()
                }
            }
        }
        
        init(allReadyCallback: @escaping AllReadyCallback) {
            self.allReadyCallback = allReadyCallback
        }
        
        private func isAllDone() -> Bool {
            for (_, check) in checks {
                if !check {
                    return false
                }
            }
            return true
        }
    }
    
    private var readyForNotifs: ReadyForNotifications!
    
    private func setupReadyForNotifs() {
        readyForNotifs = ReadyForNotifications(allReadyCallback: {
            print("All ready, let them notifs come!")
            self.addNotifications()
        })
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            self.readyForNotifs.checks[ReadyForNotifications.PERMISSION_GRANTED] = true
        })
        
        /*
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.subtitle = "Subtitle"
        content.badge = 1
        content.body = "This is a notification"
        //content.sound =
        
        //let trigger = UNCalendarNotificationTrigger(dateMatching: <#T##DateComponents#>, repeats: <#T##Bool#>)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("added notif request yay")
            }
        })
         */
    }
    
    private func addNotifications() {
        for game in toPlayList {
            addNotification(forGame: game)
        }
    }
    
    private func addNotification(forGame game: Game) {
        print(game)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toPlayList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToPlayListCell.reuseIdentifier, for: indexPath) as? ToPlayListCell {
            if let game = toPlayList[indexPath.row] {
                cell.update(game)
            }
            cell.networkErrorHandlerDelegate = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GameDetailsVC {
            if let i = collectionView.indexPathsForSelectedItems?[0] {
                let game = toPlayList[i.row]
                destinationVC.game = game
            }
        }
    }
}







