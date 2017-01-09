//
//  ToPlayListUnitTests.swift
//  ToPlayListUnitTests
//
//  Created by Máthé Levente on 2017. 01. 07..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayList

class NewestReleases: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGameSectionCreator() {
        // the games array returned by the api
        var games = [Game]()
        // the games array split up into chunks to simulate loading more games
        var gameses = [[Game]]()
        
        let exp = expectation(description: "Getting data from server to check GameSection")
        
        // how many games per request, how many times
        let increment = 10
        let iterations = 5
        let limit = iterations * increment
        
        IGDB.instance.getGamesList({ result in
            switch result {
            case .succes(let gamesResult):
                games = gamesResult
                exp.fulfill()
            default:
                break
            }
        }, withLimit: limit)
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("error: \(error)")
            }
            for i in 0..<iterations {
                gameses.append(Array<Game>(games[i*increment..<i*increment+increment]))                
            }
            
            var gameSections = [GameSection]()
            gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: gameses[0])
            for i in 1..<iterations {
                GameSection.buildGameSectionsForNewestGames(fromGames: gameses[i], continuationOf: &gameSections)
            }
            
            for gameSection in gameSections {
                let header = gameSection.header
                for game in gameSection.games {
                    XCTAssert(game.firstReleaseDateAsString == header)
                    //print("header: \(header) game: \(game.firstReleaseDateAsString!) \(game.firstReleaseDate!) \(game.name)")
                }
            }
        }
    }
    
    func testGotAllRequestResults() {
        let exp = expectation(description: "Getting data from server to check data")
        
        let date = Double(1483633380)
        let expectedGameIDs = [26655, 26695, 26364, 26691, 18322, 19168, 1943, 18426, 20149, 15013, 13158, 22367, 24934, 25959, 26680, 26649, 26481, 26665, 26632, 26678, 26620, 26598, 26589, 26629, 26362, 26619, 2165, 19000, 11078, 26618, 26596, 26585, 26650, 26604, 26595, 26593, 26592, 26591, 13205, 16468, 26590, 26581, 26486, 26210, 19465, 23981, 23796, 26536, 26443, 26442]
        var games = [Game]()
        
        IGDB.instance.getGamesList({ result in
            switch result {
            case .succes(let gamesResult):
                games = gamesResult
                exp.fulfill()
            default:
                break
            }
        }, withLimit: expectedGameIDs.count, withDate: date)
        
        waitForExpectations(timeout: 10) { error in
            for i in 0..<expectedGameIDs.count {
                if let error = error {
                    XCTFail("error: \(error)")
                }
                let expGameID = expectedGameIDs[i]
                let gameID = games[i].id
                //print("expected: \(expGameID), real: \(gameID)")
                XCTAssert(expGameID == gameID)
            }
        }
    }
}








