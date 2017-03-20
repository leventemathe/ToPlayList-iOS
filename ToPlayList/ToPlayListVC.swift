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
    
    override func viewWillAppear(_ animated: Bool) {
        getToPlayList {
            self.attachListeners()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
    
    private func removeListeners() {
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
            
            switch result {
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            case .succes(let list):
                self.toPlayList = list
            }
            self.setContent()
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
}







