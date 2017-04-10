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
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    private var shouldRemovePlayedListListenerAdd = 0
    private var shouldRemovePlayedListListenerRemove = 0
    
    var errorHandlerDelegate: ErrorHandlerDelegate?

    func attachListeners(withOnAddedToToPlayList onAddedToToPlayList: @escaping (Game)->(),
                         withOnRemovedFromToPlayList onRemovedFromToPlayList: @escaping (Game)->(),
                         withOnAddedToPlayedList onAddedToPlayedList: @escaping (Game)->(),
                         withOnRemovedFromPlayedList onRemovedFromPlayedList: @escaping (Game)->()) {
        if !ListsUser.loggedIn {
            return
        }
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
        ListsList.instance.listenToList(list, withAction: action, withListenerAttached: { result in
            switch result {
            case .succes(let ref):
                self.listListenerAttachmentSuccesful(list, withAction: action, forReference: ref)
            case .failure(let error):
                switch error {
                default:
                    self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
                }
            }
        }, withOnChange: { result in
            switch result {
            case .succes(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
                }
            }
        })
    }
    
    private func listListenerAttachmentSuccesful(_ list: String, withAction action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            if list == ListsEndpoints.List.TO_PLAY_LIST {
                self.toPlayListListenerAdd = ref
                self.removeLateToPlayListListenerAdd()
            } else if list == ListsEndpoints.List.PLAYED_LIST {
                self.playedListListenerAdd = ref
                self.removeLatePlayedListListenerAdd()
            }
        case .remove:
            if list == ListsEndpoints.List.TO_PLAY_LIST {
                self.toPlayListListenerRemove = ref
                self.removeLateToPlayListListenerRemove()
            } else if list == ListsEndpoints.List.PLAYED_LIST {
                self.playedListListenerRemove = ref
                self.removeLatePlayedListListenerRemove()
            }
        }
    }
    
    private func removeLateToPlayListListenerAdd() {
        if shouldRemoveToPlayListListenerAdd > 0 {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
            shouldRemoveToPlayListListenerAdd -= 1
        }
    }
    
    private func removeLatePlayedListListenerAdd() {
        if shouldRemovePlayedListListenerAdd > 0 {
            playedListListenerAdd!.removeListener()
            playedListListenerAdd = nil
            shouldRemovePlayedListListenerAdd -= 1
        }
    }
    
    private func removeLateToPlayListListenerRemove() {
        if shouldRemoveToPlayListListenerRemove > 0 {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
            shouldRemoveToPlayListListenerRemove -= 1
        }
    }
    
    private func removeLatePlayedListListenerRemove() {
        if shouldRemovePlayedListListenerRemove > 0 {
            playedListListenerRemove!.removeListener()
            playedListListenerRemove = nil
            shouldRemovePlayedListListenerRemove -= 1
        }
    }
    
    func detachListeners() {
        detachToPlayListListenerAdd()
        detachPlayedListListenerAdd()
        detachToPlayListListenerRemove()
        detachPlayedListListenerRemove()
    }
    
    private func detachToPlayListListenerAdd() {
        if toPlayListListenerAdd != nil {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
        } else {
            shouldRemoveToPlayListListenerAdd += 1
        }
    }
    
    private func detachPlayedListListenerAdd() {
        if playedListListenerAdd != nil {
            playedListListenerAdd!.removeListener()
            playedListListenerAdd = nil
        } else {
            shouldRemovePlayedListListenerAdd += 1
        }
    }
    
    private func detachToPlayListListenerRemove() {
        if toPlayListListenerRemove != nil {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
        } else {
            shouldRemoveToPlayListListenerRemove += 1
        }
    }
    
    private func detachPlayedListListenerRemove() {
        if playedListListenerRemove != nil {
            playedListListenerRemove!.removeListener()
            playedListListenerRemove = nil
        } else {
            shouldRemovePlayedListListenerRemove += 1
        }
    }
}
