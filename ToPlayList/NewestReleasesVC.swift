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
        print("newest")
    }
    
    override func initialLoadGames() {
        IGDB.instance.getNewestGames({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.initialLoadGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    override func reloadGames() {
        IGDB.instance.getNewestGames({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.relaodGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    override func loadMoreGames() {
        paginationOffset += paginationLimit
        IGDB.instance.getNewestGames({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.loadMoreGamesResultPacker)
        }, withLimit: paginationLimit, withOffset: paginationOffset)
    }
}






