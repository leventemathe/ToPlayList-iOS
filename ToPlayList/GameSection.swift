//
//  SectionedListBuilder.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class GameSection {
    let header: String
    var games: [Game]
    
    init(header: String, games: [Game]) {
        self.header = header
        self.games = games
    }
 
    static func buildGameSectionsForNewestGames(fromGames games: [Game]) -> [GameSection] {
        var gameSections = [GameSection]()
        var tempGames = [Game]()
        
        var prevGame = games[0]
        tempGames.append(prevGame)

        buildGameSectionLoop(1, fromGames: games, intoGameSection: &gameSections, withTempGames: &tempGames, withPrevGame: &prevGame)
        
        return gameSections
    }
    
    static func buildGameSectionsForNewestGames(fromGames games: [Game], continuationOf prevGameSections: inout [GameSection]) {
        var tempGames = [Game]()
        
        var prevGame = prevGameSections.last!.games.last!
        
        var j = 0
        while j < games.count {
            let game = games[j]
            if game.firstReleaseDate == nil || prevGame.firstReleaseDate == nil {
                tempGames.append(game)
            }
            else if game.firstReleaseDate! < prevGame.firstReleaseDate! {
                prevGameSections[prevGameSections.count - 1].games.append(contentsOf: tempGames)
                tempGames = [Game]()
                tempGames.append(game)
                prevGame = game
                j += 1
                if let lastGame = games.last {
                    if game == lastGame {
                        prevGameSections.append(GameSection(header: game.firstReleaseDateAsString!, games: tempGames))
                    }
                }
                break
            } else {
                tempGames.append(game)
                if let lastGame = games.last {
                    if game == lastGame && prevGameSections.count > 0 {
                        prevGameSections[prevGameSections.count - 1].games.append(contentsOf: tempGames)
                    }
                }
            }
            prevGame = game
            j += 1
        }
        
        buildGameSectionLoop(j, fromGames: games, intoGameSection: &prevGameSections, withTempGames: &tempGames, withPrevGame: &prevGame)
    }
    
    private static func buildGameSectionLoop(_ startIndex: Int, fromGames games: [Game], intoGameSection gameSections: inout [GameSection], withTempGames tempGames: inout [Game], withPrevGame prevGame: inout Game) {
        for i in startIndex..<games.count {
            let game = games[i]
            if game.firstReleaseDate == nil || prevGame.firstReleaseDate == nil {
                tempGames.append(game)
            } else if game.firstReleaseDate! < prevGame.firstReleaseDate! {
                gameSections.append(GameSection(header: prevGame.firstReleaseDateAsString!, games: tempGames))
                tempGames = [Game]()
                tempGames.append(game)
                if let lastGame = games.last {
                    if game == lastGame {
                        gameSections.append(GameSection(header: game.firstReleaseDateAsString!, games: tempGames))
                    }
                }
            } else {
                tempGames.append(game)
                if let lastGame = games.last {
                    if game == lastGame && gameSections.count > 0 {
                        if gameSections[gameSections.count - 1].header == game.firstReleaseDateAsString {
                            gameSections[gameSections.count - 1].games.append(contentsOf: tempGames)
                        } else {
                            gameSections.append(GameSection(header: game.firstReleaseDateAsString!, games: tempGames))
                        }
                    }
                }
            }
            prevGame = game
        }
    }
}
