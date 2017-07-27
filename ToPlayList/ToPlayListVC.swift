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
            self.removeTabBarBadge()
            if self.shouldNavigateToGame != nil {
                self.navigateToGame(withName: self.shouldNavigateToGame!)
            }
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
        
        // add a badge to the game and the tab bar when a notif arrives in the foreground
        ToPlayListNotificationSystem.instance?.notifArrivedObservers.append({ gameName in
            
        })
        
        ToPlayListNotificationSystem.instance?.notifArrivedObservers.append({ _ in
            self.addTabBarBadge()
        })
        
        // add a badge to the game and move to the list when the notif is tapped (either in foreground or background)
        ToPlayListNotificationSystem.instance?.notifTappedObservers.append({ gameName in
            guard let tabController = self.tabBarController else {
                return
            }
            if tabController.selectedIndex == self.TAB_BAR_INDEX {
                self.navigateToGame(withName: gameName)
            } else {
                self.moveToListTab()
                self.shouldNavigateToGame = gameName
            }
        })
    }
    
    private func moveToListTab() {
        tabBarController?.selectedIndex = TAB_BAR_INDEX
    }
    
    private var shouldNavigateToGame: String? = nil
    
    private func navigateToGame(withName name: String) {
        shouldNavigateToGame = nil
        
        var indexPath: IndexPath? = nil
        for (index, game) in toPlayList.enumerated() {
            if game.name == name {
                indexPath = IndexPath(row: index, section: 0)
                break
            }
        }
        if let indexPath = indexPath {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
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







