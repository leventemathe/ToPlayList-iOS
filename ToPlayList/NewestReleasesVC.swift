//
//  ViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit
import Kingfisher

class NewestReleasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: ShadowyView!
    
    private var noDataLbl = UILabel()
    private var refreshVC = UIRefreshControl()
    
    private var gameSections = [GameSection]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let paginationLimit = 10
    private var paginationOffset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navBar.addDropShadow()
        
        noDataLbl.bounds = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: tableView.bounds.height)
        noDataLbl.text = "No data. Pull to refresh!"
        noDataLbl.textAlignment = NSTextAlignment.center
        noDataLbl.sizeToFit()
        
        refreshVC.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshVC)
        
        reloadGames()
    }

    @objc private func refresh(_ sender: AnyObject) {
        reloadGames()
    }
    
    private func reloadGames() {
        IGDB.instance.getNewestGamesList({ result in
            self.handleLoadingGames(from: result, likeFunction: self.relaodGamesHandler)
        }, withLimit: paginationLimit)
    }
    
    private func relaodGamesHandler(_ games: [Game]) {
        self.gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: games)
    }
    
    private func loadMoreGames() {
        paginationOffset += paginationLimit
        IGDB.instance.getNewestGamesList ({ result in
            self.handleLoadingGames(from: result, likeFunction: self.loadMoreGamesHandler)
        }, withLimit: paginationLimit, withOffset: paginationOffset)
    }
    
    private func loadMoreGamesHandler(_ games: [Game]) {
        self.gameSections.append(contentsOf: GameSection.buildGameSectionsForNewestGames(fromGames: games, continuationOf: &self.gameSections))
    }
    
    private func handleLoadingGames(from result: IGDBResult<[Game]>, likeFunction this: ([Game])->Void) {
        switch result {
        case .succes(let games):
            this(games)
            self.resetListBackground()
        case .failure(let error):
            self.setListBackground()
            switch error {
            case .serverError, .urlError, .jsonError:
                self.presentNetworkingError(withMessage: "There was an error with the server, please check back later!")
                break
            case .noInternetError:
                self.presentNetworkingError(withMessage: "No internet connection!")
                break
            }
        }
        self.refreshVC.endRefreshing()
    }
    
    private func setListBackground() {
        if(gameSections.count > 0) {
            return
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundView = noDataLbl
    }
    
    private func resetListBackground() {
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }

    private func presentNetworkingError(withMessage message: String) {
        let alert = UIAlertController(title: "Error 😟", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewestReleasesCell.reuseIdentifier, for: indexPath) as? NewestReleasesCell {
            let game = gameSections[indexPath.section].games[indexPath.row]
            cell.update(game)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(20.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("DateTableCellHeaderView", owner: self, options: nil)?.first as! DateTableCellHeaderView
        headerView.dateLbl.text = gameSections[section].header
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameSections[section].games.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && paginationOffset < 10 {
            loadMoreGames()
        }
    }
}






