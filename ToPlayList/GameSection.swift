//
//  SectionedListBuilder.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct GameSection {
    let header: String
    var games: [Game]
    
    static func buildGameSectionsForNewestGames(from games: [Game]) -> [GameSection] {
        var prevGame = games[0]
        
        var gameSections = [GameSection]()
        var tempGames = [Game]()
        tempGames.append(prevGame)
        
        for i in 1..<games.count {
            let game = games[i]
            if game.firstReleaseDate == nil || prevGame.firstReleaseDate == nil {
                tempGames.append(game)
            } else if game.firstReleaseDate! < prevGame.firstReleaseDate! {
                gameSections.append(GameSection(header: prevGame.firstReleaseDateAsString!, games: tempGames))
                tempGames = [Game]()
                tempGames.append(game)
            } else if game == games[games.count-1] {
                tempGames.append(game)
                gameSections[gameSections.count-1].games.append(contentsOf: tempGames)
            } else {
                tempGames.append(game)
            }
            prevGame = game
        }
        return gameSections
    }
}
