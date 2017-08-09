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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getToPlayList {
            self.attachListeners()
            self.removeTabBarBadge()
            if self.releasedGames != nil {
                self.addBadgeToReleasedGames()
            }
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
        ToPlayListNotificationSystem.instance?.addNotificationArrivedObserver({ gameName in
            self.setupAddBadgeToReleasedGame(withName: gameName)
            self.addTabBarBadge()
        }, withName: "toPlayListBadge")
        
        // add a badge to the game and move to the list when the notif is tapped (either in foreground or background)
        ToPlayListNotificationSystem.instance?.addNotificationTappedObserver({ gameName in
            self.setupAddBadgeToReleasedGame(withName: gameName)
            self.setupNavigationToGame(withName: gameName)
        }, withName: "toPlayListNavigation")
    }

    // insertIntoReleasedGames and shouldNavigateToGame are needed, because the game is not necessarily in the to play list when the block is called
    // this can happen for example if a game is added to a list, but the list is not visited before the notif arrives
    private func setupAddBadgeToReleasedGame(withName gameName: String) {
        guard let tabController = self.tabBarController else {
            return
        }
        
        if tabController.selectedIndex == self.TAB_BAR_INDEX {
            if let _ = detailedVC() {
                self.insertIntoReleasedGames(gameName)
            } else {
                self.addBadgeToReleasedGame(withName: gameName)
                // this is needed when the block is called before the list had downloaded: when the notif was tapped when the app wasn't running
                self.insertIntoReleasedGames(gameName)
            }
        } else {
            self.insertIntoReleasedGames(gameName)
        }
    }
    
    private func setupNavigationToGame(withName gameName: String) {
        guard let tabController = self.tabBarController else {
            return
        }
        
        if tabController.selectedIndex == self.TAB_BAR_INDEX {
            if let detailedVC = detailedVC() {
                self.shouldNavigateToGame = gameName
                detailedVC.back(sender: nil)
            } else {
                self.navigateToGame(withName: gameName)
            }
        } else {
            self.shouldNavigateToGame = gameName
            if let detailedVC = detailedVC() {
                detailedVC.back(sender: nil)
            }
            self.moveToListTab()
        }
    }
    
    private var releasedGames: Set<String>?
    
    private func insertIntoReleasedGames(_ name: String) {
        if releasedGames == nil {
            releasedGames = Set<String>()
        }
        releasedGames?.insert(name)
    }
    
    private func addBadgeToReleasedGames() {
        releasedGames?.forEach({ addBadgeToReleasedGame(withName: $0) })
        releasedGames = nil
    }
    
    private func addBadgeToReleasedGame(withName name: String) {
        for game in toPlayList {
            if game.name == name {
                game.released = true
                if let indexPath = getIndexPathForGame(withName: name) {
                    if let cell = collectionView.cellForItem(at: indexPath) as? ToPlayListCell {
                        cell.update(game)
                    }
                }
                break
            }
        }
    }
    
    private func moveToListTab() {
        tabBarController?.selectedIndex = TAB_BAR_INDEX
    }
    
    private var shouldNavigateToGame: String? = nil
    
    private func navigateToGame(withName name: String) {
        shouldNavigateToGame = nil
        
        if let indexPath = getIndexPathForGame(withName: name) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }

    private func detailedVC() -> GameDetailsVC? {
        if let navVC = navigationController{
            for vc in navVC.viewControllers {
                if let detailsVC = vc as? GameDetailsVC {
                    return detailsVC
                }
            }
        }
        return nil
    }
    
    private func getIndexPathForGame(withName name: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        for (index, game) in toPlayList.enumerated() {
            if game.name == name {
                indexPath = IndexPath(row: index, section: 0)
                break
            }
        }
        return indexPath
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
        let listeningResult = ListsList.instance.listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: action, withOnChange: { result in
            switch result {
            case .success(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        })
        
        switch listeningResult {
        case .success(let ref):
            self.listListenerAttachmentSuccesful(action, forReference: ref)
        case .failure(let error):
            switch error {
            default:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
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
    
    func removeListeners() {
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
            case .success(let list):
                if list.count > 0 && self.toPlayList == list {
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







