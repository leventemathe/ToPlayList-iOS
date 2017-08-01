//
//  UpcomingReleases.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 22..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayList

class UpcomingReleases: XCTestCase {
    
    private var games: [Game]!
    private let INCREMENT = 10
    private let ITERATIONS = 5
    private let LIMIT = 10 * 5
    
    override func setUp() {
        super.setUp()
        
        let exp = expectation(description: "Getting data from server to check GameSection")
        
        IGDB.instance.getUpcomingGames({ result in
            switch result {
            case .success(let gamesResult):
                self.games = gamesResult
                exp.fulfill()
            default:
                XCTFail()
            }
        }, withLimit: LIMIT)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    
    func testGameSectionCreator() {
        check(gameSections: GameSection.buildGameSectionsForUpcomingGames(fromGames: games))
    }
    
    func testGameSectionCreatorContinuation() {
        var gameses = [[Game]]()
        
        for i in 0..<ITERATIONS {
            gameses.append([Game](games[i*INCREMENT..<i*INCREMENT+INCREMENT]))
        }
        
        var gameSections = [GameSection]()
        gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: gameses[0])
        for i in 1..<ITERATIONS {
            GameSection.buildGameSectionsForNewestGames(fromGames: gameses[i], continuationOf: &gameSections)
        }
        
        check(gameSections: gameSections)
    }
    
    private func check(gameSections: [GameSection]) {
        for gameSection in gameSections {
            let header = gameSection.header
            for game in gameSection.games {
                XCTAssert(game.firstReleaseDateAsString == header)
                //print("header: \(header) game: \(game.firstReleaseDateAsString!) \(game.firstReleaseDate!) \(game.name)")
            }
        }
    }
}









