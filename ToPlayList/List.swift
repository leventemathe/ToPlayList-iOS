//
//  List.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 19..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class List {
    
    var type: String!
    private var _games = Set<Game>()
    
    init(_ type: String) {
        self.type = type
    }
    
    func add(_ game: Game) {
        _games.insert(game)
    }
    
    func add(_ games: List) {
        for game in games._games {
            _games.insert(game)
        }
    }
    
    func clear() {
        _games.removeAll()
    }
    
    func contains(_ game: Game) -> Bool {
        return _games.contains(game)
    }
}
