//
//  ViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit
import Kingfisher

class NewestReleasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorHandlerDelegate, ListChangedDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var noDataLbl = UILabel()
    private var refreshVC = UIRefreshControl()
    
    private var loadingMoreGames = true
    
    private var _gameSections = [GameSection]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public var gameSections: [GameSection] {
        return _gameSections
    }
    
    private let paginationLimit = 10
    private var paginationOffset = 0
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST)
    private var playedList = List(ListsEndpoints.List.PLAYED_LIST)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        noDataLbl.bounds = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: tableView.bounds.height)
        noDataLbl.text = "No data. Pull to refresh!"
        noDataLbl.textAlignment = NSTextAlignment.center
        noDataLbl.sizeToFit()
        
        refreshVC.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshVC)
        
        reloadGames()
        loadLists {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if gameSections.count > 0 {
            tableView.reloadData()
        }
    }
    
    private func loadLists(_ onComplete: @escaping ()->()) {
        var toplayListLoaded = false
        var playedListLoaded = false
        loadToPlayList {
            toplayListLoaded = true
            if playedListLoaded {
                onComplete()
            }
        }
        loadPlayedList {
            playedListLoaded = true
            if toplayListLoaded {
                onComplete()
            }
        }
    }
    
    private func loadToPlayList(_ onComplete: @escaping ()->()) {
        ListsList.instance.getToPlayList { result in
            switch result {
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            case .succes(let list):
                self.toPlayList.add(list)
                onComplete()
            }
        }
    }
    
    private func loadPlayedList(_ onComplete: @escaping ()->()) {
        ListsList.instance.getPlayedList { result in
            switch result {
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            case .succes(let list):
                self.playedList.add(list)
                onComplete()
            }
        }
    }

    @objc private func refresh(_ sender: AnyObject) {
        reloadGames()
    }
    
    func reloadGames() {
        IGDB.instance.getGamesList({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.relaodGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    private func relaodGamesResultPacker(_ games: [Game]) {
        self._gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: games)
        self.paginationOffset = 0
    }
    
    func loadMoreGames() {
        paginationOffset += paginationLimit
        IGDB.instance.getGamesList ({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.loadMoreGamesResultPacker)
        }, withLimit: paginationLimit, withOffset: paginationOffset)
    }
    
    private func loadMoreGamesResultPacker(_ games: [Game]) {
        GameSection.buildGameSectionsForNewestGames(fromGames: games, continuationOf: &self._gameSections)
    }
    
    private func handleLoadingGames(fromResult result: IGDBResult<[Game]>, withResultPacker packer: ([Game])->Void) {
        switch result {
        case .succes(let games):
            packer(games)
            self.resetListBackground()
        case .failure(let error):
            self.setListBackground()
            switch error {
            case .serverError, .urlError, .jsonError:
                Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                break
            case .noInternetError:
                Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                break
            }
        }
        self.refreshVC.endRefreshing()
        loadingMoreGames = false
    }
    
    private func setListBackground() {
        if(_gameSections.count > 0) {
            return
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundView = noDataLbl
    }
    
    private func resetListBackground() {
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _gameSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewestReleasesCell.reuseIdentifier, for: indexPath) as? NewestReleasesCell {
            cell.networkErrorHandlerDelegate = self
            cell.listChangedDelegate = self
            let game = _gameSections[indexPath.section].games[indexPath.row]
            cell.update(game)
            cell.updateStar(gameIsInList(game))
            return cell
        }
        
        return UITableViewCell()
    }
    
    func gameIsInList(_ game: Game) -> StarState {
        if toPlayList.contains(game) {
            return .toPlay
        } else if playedList.contains(game) {
            return .played
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(20.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("DateTableCellHeaderView", owner: self, options: nil)?.first as! DateTableCellHeaderView
        headerView.dateLbl.text = _gameSections[section].header
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _gameSections[section].games.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        
        if position > height - scrollView.frame.size.height * 1.5 && !loadingMoreGames && _gameSections.count != 0 {
            loadingMoreGames = true
            loadMoreGames()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GameDetailsVC {
            if let i = tableView.indexPathForSelectedRow {
                let game = gameSections[i.section].games[i.row]
                destinationVC.game = game
            }
        }
    }
    
    func handleError(_ message: String) {
        Alerts.alertWithOKButton(withMessage: message, forVC: self)
    }
    
    func listChanged(_ starState: StarState, forGame game: Game) {
        switch starState {
        case .toPlay:
            toPlayList.add(game)
        case .played:
            playedList.add(game)
        default:
            break
        }
    }
}






