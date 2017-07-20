//
//  UpcomingReleases.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class UpcomingReleasesVC: ReleasesVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("upcoming")
    }
    
    override func initialLoadGames() {
        IGDB.instance.getUpcomingGames({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.initialLoadGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    override func reloadGames() {
        IGDB.instance.getUpcomingGames({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.relaodGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    override func loadMoreGames() {
        paginationOffset += paginationLimit
        IGDB.instance.getUpcomingGames({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.loadMoreGamesResultPacker)
        }, withLimit: paginationLimit, withOffset: paginationOffset)
    }
}
