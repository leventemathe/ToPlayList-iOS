//
//  ViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView

class NewestReleasesVC: ReleasesVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initialLoadGames() {
        IGDB.instance.getNewestGames({ result in
            self.handleLoadingGames(fromResult: result, fromLocation: .reload, withResultPacker: self.initialLoadGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    override func reloadGames() {
        IGDB.instance.getNewestGames({ result in
            self.handleLoadingGames(fromResult: result, fromLocation: .reload, withResultPacker: self.relaodGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    override func loadMoreGames() {
        paginationOffset += paginationLimit
        IGDB.instance.getNewestGames({ result in
            self.handleLoadingGames(fromResult: result, fromLocation: .loadMore, withResultPacker: self.loadMoreGamesResultPacker)
        }, withLimit: paginationLimit, withOffset: paginationOffset)
    }
    
    override func initialLoadGamesResultPacker(_ games: [Game]) {
        gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: games)
        paginationOffset = 0
        animateTableViewAppearance()
    }
    
    override func relaodGamesResultPacker(_ games: [Game]) {
        gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: games)
        paginationOffset = 0
    }
    
    override func loadMoreGamesResultPacker(_ games: [Game]) {
        GameSection.buildGameSectionsForNewestGames(fromGames: games, continuationOf: &gameSections)
    }
}






