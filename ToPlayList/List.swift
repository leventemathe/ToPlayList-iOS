//
//  List.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 19..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class List: Hashable, Equatable {
    
    var type: String!
    private var _games = Set<Game>()
    
    init(_ type: String) {
        self.type = type
    }
    
    var count: Int {
        return _games.count
    }

    func add(_ game: Game) -> Bool{
        let result = _games.insert(game)
        return result.inserted
    }
    
    func add(_ games: List) {
        for game in games._games {
            _games.insert(game)
        }
    }
    
    func remove(_ game: Game) {
        _games.remove(game)
    }
    
    func clear() {
        _games.removeAll()
    }
    
    func contains(_ game: Game) -> Bool {
        return _games.contains(game)
    }
    
    var hashValue: Int {
        return _games.reduce(_games.count, {$0 + Int($1.id)})
    }
    
    static func ==(lhs: List, rhs: List) -> Bool {
        return lhs._games == rhs._games
    }
}
