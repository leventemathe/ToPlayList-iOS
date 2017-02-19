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
    private var _games = [Game]()
    
    init(_ type: String) {
        self.type = type
    }
    
    func add(_ game: Game) {
        _games.append(game)
    }
    
    func add(_ games: [Game]) {
        _games.append(contentsOf: games)
    }
    
    func clear() {
        _games.removeAll()
    }
    
    subscript(_ i: Int) -> Game {
        get {
            return _games[i]
        }
    }
}
