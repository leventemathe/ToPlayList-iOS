//
//  ToPlayAndPlayedListListeners.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 10..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class ToPlayAndPlayedListListeners {
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var playedListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    private var playedListListenerRemove: ListsListenerReference?
    
    func isAttached() -> Bool {
        if toPlayListListenerAdd == nil {
            return false
        }
        if playedListListenerAdd == nil {
            return false
        }
        if toPlayListListenerRemove == nil {
            return false
        }
        if playedListListenerRemove == nil {
            return false
        }
        return true
    }
    
    weak var errorHandlerDelegate: ErrorHandlerDelegate?

    func attachListeners(withOnAddedToToPlayList onAddedToToPlayList: @escaping (Game)->(),
                         withOnRemovedFromToPlayList onRemovedFromToPlayList: @escaping (Game)->(),
                         withOnAddedToPlayedList onAddedToPlayedList: @escaping (Game)->(),
                         withOnRemovedFromPlayedList onRemovedFromPlayedList: @escaping (Game)->()) {

        listenToToPlayListAdd(onAddedToToPlayList)
        listenToPlayedListAdd(onAddedToPlayedList)
        listenToToPlayListRemove(onRemovedFromToPlayList)
        listenToPlayedListRemove(onRemovedFromPlayedList)
    }
    
    private func listenToToPlayListAdd(_ onAddedToToPlayList: @escaping (Game)->()) {
        listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .add) { game in
            onAddedToToPlayList(game)
        }
    }
    
    private func listenToPlayedListAdd(_ onAddedToPlayedList: @escaping (Game)->()) {
        listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .add) { game in
            onAddedToPlayedList(game)
        }
    }
    
    private func listenToToPlayListRemove(_ onRemovedFromToPlayList: @escaping (Game)->()) {
        listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .remove) { game in
            onRemovedFromToPlayList(game)
        }
    }
    
    private func listenToPlayedListRemove(_ onRemovedFromPlayedList: @escaping (Game)->()) {
        listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .remove) { game in
            onRemovedFromPlayedList(game)
        }
    }
    
    private func listenToList(_ list: String, withAction action: ListsListenerAction, withOnChange onChange: @escaping (Game)->()) {
        let listeningResult = ListsList.instance.listenToList(list, withAction: action, withOnChange: { result in
            switch result {
            case .success(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
                }
            }
        })
        
        switch listeningResult {
        case .success(let ref):
            self.listListenerAttachmentSuccesful(list, withAction: action, forReference: ref)
        case .failure(let error):
            switch error {
            default:
                self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
            }
        }
    }
    
    private func listListenerAttachmentSuccesful(_ list: String, withAction action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            if list == ListsEndpoints.List.TO_PLAY_LIST {
                self.toPlayListListenerAdd = ref
            } else if list == ListsEndpoints.List.PLAYED_LIST {
                self.playedListListenerAdd = ref
            }
        case .remove:
            if list == ListsEndpoints.List.TO_PLAY_LIST {
                self.toPlayListListenerRemove = ref
            } else if list == ListsEndpoints.List.PLAYED_LIST {
                self.playedListListenerRemove = ref
            }
        }
    }
    
    func detachListeners() {
        detachToPlayListListenerAdd()
        detachPlayedListListenerAdd()
        detachToPlayListListenerRemove()
        detachPlayedListListenerRemove()
    }
    
    private func detachToPlayListListenerAdd() {
        toPlayListListenerAdd?.removeListener()
        toPlayListListenerAdd = nil
    }
    
    private func detachPlayedListListenerAdd() {
        playedListListenerAdd?.removeListener()
        playedListListenerAdd = nil
    }
    
    private func detachToPlayListListenerRemove() {
        toPlayListListenerRemove?.removeListener()
        toPlayListListenerRemove = nil
    }
    
    private func detachPlayedListListenerRemove() {
        playedListListenerRemove?.removeListener()
        playedListListenerRemove = nil
    }
}
