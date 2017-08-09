//
//  Lists.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 03..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayList

class ListsSuccesful: XCTestCase {
    
    private let userData = (email: "levi@levi.com", password: "Llevilevi1", username: "levi")
    
    private let game = Game(123, withName: "A test game")
    private let gameWithCover = Game(1234, withName: "A test game with cover")
    
    override func setUp() {
        super.setUp()
        
        RegisterLoginTestHelper.register(userData, withOnSuccess: { result in
            XCTAssertTrue(true, "Register succesful in setup")
        }, withOnFailure: { error in
            XCTAssertTrue(false, "Register failed in setup")
        })
        
        game.provider = "IGDB"
        
        gameWithCover.provider = "IGDB"
        gameWithCover.coverSmallURL = URL(string: "https://www.example.com/s/123.jpeg")!
        gameWithCover.coverBigURL = URL(string: "https://www.example.com/l/123.jpeg")!
    }
    
    override func tearDown() {
        RegisterLoginTestHelper.deleteUserCompletely(userData)
        super.tearDown()
    }
    
    func testGameToPlayList() {
        let exp = expectation(description: "Game added to list")
        
        ListsList.instance.addGameToToPlayList({ result in
            switch result {
            case .success(_):
                XCTAssertTrue(true, "Succesfully added game to to play list")
            case .failure(let error):
                XCTAssertTrue(false, "Adding game to to play list failed with error: \(error)")
            }
            exp.fulfill()
        }, thisGame: game)
        
        waitForExpectations(timeout: 15, handler: { error in
            XCTAssertTrue(error == nil, "There was an error: \(error!)")
            XCTAssertTrue(self.doesListContainGame(list: ListsEndpoints.List.TO_PLAY_LIST, game: self.game), "To play list contains game")
            XCTAssertTrue(!self.doesListContainGame(list: ListsEndpoints.List.PLAYED_LIST, game: self.game), "Played list doesn't contain game")
        })
    }
    
    private func doesListContainGame(list: String, game: Game) -> Bool {
        let exp = self.expectation(description: "List retrieved")
        var funcResult = false
        
        ListsList.instance.getList(list, withOnComplete: { result in
            switch result {
            case .success(let list):
                funcResult = list.contains(game)
            case .failure(let error):
                print("An error happened while retrieving list: \(error)")
                funcResult = false
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 15, handler: nil)
        return funcResult
    }
    
    func testGameWithCoverToPlayList() {
        ListsList.instance.addGameToToPlayList({ result in
            switch result {
            case .success(_):
                XCTAssertTrue(true, "Succesfully added game with cover to to play list")
            case .failure(let error):
                XCTAssertTrue(false, "Adding game with cover to to play list failed with error: \(error)")
            }
        }, thisGame: gameWithCover)
    }
    
    func testGamePlayedList() {
        let exp = expectation(description: "Game added to list")
        
        ListsList.instance.addGameToPlayedList({ result in
            switch result {
            case .success(_):
                XCTAssertTrue(true, "Succesfully added game to played list")
            case .failure(let error):
                XCTAssertTrue(false, "Adding game to played list failed with error: \(error)")
            }
            exp.fulfill()
        }, thisGame: game)
        
        waitForExpectations(timeout: 15, handler: { error in
            XCTAssertTrue(error == nil, "There was an error: \(error!)")
            XCTAssertTrue(!self.doesListContainGame(list: ListsEndpoints.List.TO_PLAY_LIST, game: self.game), "To play list doesn't contain game")
            XCTAssertTrue(self.doesListContainGame(list: ListsEndpoints.List.PLAYED_LIST, game: self.game), "Played list contains game")
        })
    }
    
    func testGameWithCoverPlayedList() {
        ListsList.instance.addGameToPlayedList({ result in
            switch result {
            case .success(_):
                XCTAssertTrue(true, "Succesfully added game with cover to played list")
            case .failure(let error):
                XCTAssertTrue(false, "Adding game with cover to played list failed with error: \(error)")
            }
        }, thisGame: gameWithCover)
    }
}



class ListsFailing: XCTestCase {
    
    private let userData = (email: "levi@levi.com", password: "Llevilevi1", username: "levi")
    
    private let gameWithoutProvider = Game(123, withName: "A test game")
    
    override func setUp() {
        super.setUp()
        RegisterLoginTestHelper.register(userData, withOnSuccess: { result in
            XCTAssertTrue(true, "Register succesful in setup")
        }, withOnFailure: { error in
            XCTAssertTrue(false, "Register failed in setup")
        })
    }
    
    override func tearDown() {
        RegisterLoginTestHelper.deleteUserCompletely(userData)
        super.tearDown()
    }
    
    func testGameWithoutProvider() {
        ListsList.instance.addGameToToPlayList({ result in
            switch result {
            case .success(_):
                XCTAssertTrue(false, "Succesfully added game without provider to toplay list")
            case .failure(let error):
                XCTAssertTrue(true, "Adding game without provider to totoplay list failed with error: \(error)")
            }
        }, thisGame: gameWithoutProvider)
    }
}









