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
 
    private static func buildSortedNewestGames(fromGames games: [Game]) -> [Game] {
        var games = games.filter({ $0.firstReleaseDate != nil })
        games = games.sorted(by: { $0.firstReleaseDate! >= $1.firstReleaseDate! })
        return games
    }
    
    static func buildGameSectionsForNewestGames(fromGames games: [Game]) -> [GameSection] {
        return buildLoop(buildSortedNewestGames(fromGames: games), startWithGame: nil)
    }
    
    static func buildGameSectionsForNewestGames(fromGames games: [Game], continuationOf previousGameSections: inout [GameSection]) {
        let newSections = buildLoop(buildSortedNewestGames(fromGames: games), startWithGame: previousGameSections.last?.games.last)
        joinPreviousWithNew(newGameSections: newSections, previousGameSections: &previousGameSections)
    }
    
    private static func buildSortedUpcomingGames(fromGames games: [Game]) -> [Game] {
        var games = games.filter({ $0.firstReleaseDate != nil })
        games = games.sorted(by: { $0.firstReleaseDate! <= $1.firstReleaseDate! })
        return games
    }
    
    static func buildGameSectionsForUpcomingGames(fromGames games: [Game]) -> [GameSection] {
        return buildLoop(buildSortedUpcomingGames(fromGames: games), startWithGame: nil)
    }
    
    static func buildGameSectionsForUpcomingGames(fromGames games: [Game], continuationOf previousGameSections: inout [GameSection]) {
        let newSections = buildLoop(buildSortedUpcomingGames(fromGames: games), startWithGame: previousGameSections.last?.games.last)
        joinPreviousWithNew(newGameSections: newSections, previousGameSections: &previousGameSections)
    }
    
    private static func buildLoop(_ games: [Game], startWithGame prevGame: Game?) -> [GameSection] {
        var gameSections = [GameSection]()
        
        var prevGame = prevGame
        for game in games {
            if prevGame == nil || game.firstReleaseDate! != prevGame!.firstReleaseDate! {
                gameSections.append(GameSection(header: game.firstReleaseDateAsString!, games: [game]))
            } else {
                if gameSections.count > 0 {
                    gameSections.last!.games.append(game)
                } else {
                    gameSections.append(GameSection(header: game.firstReleaseDateAsString!, games: [game]))
                }
            }
            prevGame = game
        }
        
        return gameSections
    }
    
    private static func joinPreviousWithNew(newGameSections: [GameSection], previousGameSections: inout [GameSection]) {
        if newGameSections.count <= 0 {
            return
        }
        
        if let lastSection = previousGameSections.last {
            if lastSection.header == newGameSections.first!.header {
                previousGameSections.last!.games.append(contentsOf: newGameSections.first!.games)
                previousGameSections.append(contentsOf: newGameSections[1..<newGameSections.count])
            } else {
                previousGameSections.append(contentsOf: newGameSections)
            }
        } else {
            previousGameSections = newGameSections
        }
    }
}
