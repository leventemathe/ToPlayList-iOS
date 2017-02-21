//
//  ListChangedDelegate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

protocol ListChangedListener {
    
    func listChanged(_ starState: StarState, forGame game: Game)
    func hashValue() -> Int
}

struct ListChangedListeners {
    
    private var listeners = [ListChangedListener]()
    
    mutating func add(_ listener: ListChangedListener) {
        for presentListener in listeners {
            if presentListener.hashValue() == listener.hashValue() {
                return
            }
        }
        listeners.append(listener)
        
    }
    
    mutating func remove(_ listener: ListChangedListener) {
        listeners = listeners.filter {
            $0.hashValue() == listener.hashValue()
        }
    }
    
    func execute(_ starState: StarState, forGame game: Game) {
        for listener in listeners {
            listener.listChanged(starState, forGame: game)
        }
    }
}
