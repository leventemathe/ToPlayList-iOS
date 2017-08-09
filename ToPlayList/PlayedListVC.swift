//
//  PlayedListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class PlayedListVC: SubListVC {
    
    private var playedList = List(ListsEndpoints.List.PLAYED_LIST)
    
    private var playedListListenerAdd: ListsListenerReference?
    private var playedListListenerRemove: ListsListenerReference?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlayedList {
            self.attachListeners()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeListeners()
    }
    
    private func attachListeners() {
        listenToPlayedList(.add, withOnChange: { game in
            if self.playedList.add(game) {
                self.setContent()
            }
        })
        listenToPlayedList(.remove, withOnChange: { game in
            self.playedList.remove(game)
            self.setContent()
        })
    }
    
    private func listenToPlayedList(_ action: ListsListenerAction, withOnChange onChange: @escaping (Game)->()) {
        let listeningResult = ListsList.instance.listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: action, withOnChange: { result in
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
            self.playedListListenerAdd = ref
        case .remove:
            self.playedListListenerRemove = ref
        }
    }
    
    func removeListeners() {
        removePlayedListListenerAdd()
        removePlayedListListenerRemove()
    }
    
    private func removePlayedListListenerAdd() {
        playedListListenerAdd?.removeListener()
        playedListListenerAdd = nil
    }
    
    private func removePlayedListListenerRemove() {
        playedListListenerRemove?.removeListener()
        playedListListenerRemove = nil
    }
    
    private func getPlayedList(_ onComplete: @escaping ()->()) {
        ListsList.instance.getPlayedList { result in
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
                if list.count > 0 && self.playedList == list {
                    shouldSetContent = false
                } else {
                    self.playedList = list
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
        //print("set content in played list")
        collectionView.reloadData()
        if playedList.count < 1 {
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
        return playedList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayedListCell.reuseIdentifier, for: indexPath) as? PlayedListCell {
            if let game = playedList[indexPath.row] {
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
                let game = playedList[i.row]
                destinationVC.game = game
            }
        }
    }
}
