//
//  List.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 19..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class List: Hashable, Equatable, Sequence, NSCopying {
    
    var type: String!
    private var _games = [Game]() {
        didSet {
            _games.sort(by: {
                if let time0 = $0.timestamp, let time1 = $1.timestamp {
                    return time0 >= time1
                }
                return true
            })
        }
    }
    
    init(_ type: String) {
        self.type = type
    }
    
    var count: Int {
        return _games.count
    }

    func add(_ game: Game) -> Bool{
        if _games.contains(game) {
            return false
        }
        _games.append(game)
        return true
    }
    
    func add(_ games: List) {
        for game in games._games {
            if  _games.contains(game) {
                continue
            }
            _games.append(game)
        }
    }
    
    func remove(_ game: Game) {
        _games = _games.filter { $0 != game }
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
    
    subscript(_ i: Int) -> Game? {
        return _games[i]
    }
    
    func get(whereGame: (Game) -> Bool) -> Game? {
        var result: Game?
        _games.forEach({ game in
            if whereGame(game) {
                result = game
            }
        })
        return result
    }
    
    func makeIterator() -> Array<Game>.Iterator {
        return _games.makeIterator()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = List(type)
        copy._games = _games
        return copy
    }
}
