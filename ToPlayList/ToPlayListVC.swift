//
//  ToPlayListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ToPlayListVC: SubListVC {
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST)
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getToPlayList {
            self.attachListeners()
            self.handleGameReleaseNotifications()
            self.removeTabBarBadge()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeListeners()
    }
    
    // this is the perfect place for app wide notifications initialization for to play list
    // it's initialized after login/register or launching the app (if already logged in)
    // it's deinitialized after logout
    private func setupNotifications() {
        ToPlayListNotificationSystem.setup()
        
        ToPlayListNotificationSystem.instance?.notifArrivedObservers.append({ gameName in
            self.releasedGameNames.insert(gameName)
            self.handleGameReleaseNotifications()
        })
        
        ToPlayListNotificationSystem.instance?.notifTappedObservers.append({ gameName in
            self.releasedGameNames.insert(gameName)
            self.handleGameReleaseNotifications()
            self.navigateToGame(gameName)
        })
        
        ToPlayListNotificationSystem.instance?.notifArrivedObservers.append({ _ in
            self.addTabBarBadge()
        })
    }
    
    private var releasedGameNames = Set<String>()
    
    // this needs to be complicated like this, becuase it's not enough to just update games in the releaseListener
    // the game list might be empty here, because the notif system is initialized before downloading the games list
    // so this has to be called after games have downloaded in this vc too
    private func handleGameReleaseNotifications() {
        var count = 0
        for releasedGameName in releasedGameNames {
            if let game = toPlayList.get(whereGame: { $0.name == releasedGameName }) {
                releasedGameNames.remove(releasedGameName)
                game.released = true
                count += 1
            }
        }
        if count > 0 {
            //print("yaya some games were released alright")
        }
    }
    
    private func navigateToGame(_ game: String) {
        return
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
            }
            onComplete()
        }
    }
    
    private var listWasEmptyLastTime: Bool?
    
    private func setContent() {
        //print("set content in toPlay list")
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
    
    private let TAB_BAR_INDEX = 0
    
    private func addTabBarBadge() {
        if let tabItems = self.tabBarController?.tabBar.items {
            if tabItems.count > self.TAB_BAR_INDEX {
                tabItems[self.TAB_BAR_INDEX].badgeValue = "new"
            }
        }
    }
    
    private func removeTabBarBadge() {
        if let tabItems = self.tabBarController?.tabBar.items {
            if tabItems.count > TAB_BAR_INDEX {
                tabItems[TAB_BAR_INDEX].badgeValue = nil
            }
        }
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







