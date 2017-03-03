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

class NewestReleasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorHandlerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var noDataLbl = UILabel()
    private var loadingAnimationView: NVActivityIndicatorView!
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
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var playedListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    private var playedListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    private var shouldRemovePlayedListListenerAdd = 0
    private var shouldRemovePlayedListListenerRemove = 0
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST)
    private var playedList = List(ListsEndpoints.List.PLAYED_LIST)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupNoDataLabel()
        setupRefreshVC()
        setupLoadingAnimation()
        initialLoadGames()
        loadingAnimationView.startAnimating()
    }
    
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNoDataLabel() {
        noDataLbl.bounds = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: tableView.bounds.height)
        noDataLbl.text = "No data. Pull to refresh!"
        noDataLbl.font = UIFont(name: "Avenir", size: 22)
        noDataLbl.textAlignment = NSTextAlignment.center
        noDataLbl.sizeToFit()
    }
    
    private func setupRefreshVC() {
        refreshVC.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshVC)
    }
    
    private func setupLoadingAnimation() {
        let width: CGFloat = 80.0
        let height: CGFloat = width
        
        let x = UIScreen.main.bounds.size.width / 2.0 - width / 2.0
        let y = UIScreen.main.bounds.size.height / 2.0 - height / 2.0
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.MyCustomColors.orange, padding: 0.0)
        view.addSubview(loadingAnimationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearStars()
        getGamesInLists {
            self.tableView.reloadData()
            self.attachListListeners()
        }
    }
    
    private func clearStars() {
        toPlayList.clear()
        playedList.clear()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeListListeners()
    }
    
    private func getGamesInLists(_ onComplete: @escaping ()->()) {
        if !ListsUser.loggedIn {
            onComplete()
            return
        }
        ListsList.instance.getToPlayAndPlayedList { result in
            switch result {
            case .failure:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            case .succes(let lists):
                self.toPlayList.add(lists.toPlay)
                self.playedList.add(lists.played)
            }
            onComplete()
        }
    }
    
    private func attachListListeners() {
        if !ListsUser.loggedIn {
            return
        }
        listenToToPlayListAdd()
        listenToPlayedListAdd()
        listenToToPlayListRemove()
        listenToPlayedListRemove()
    }
    
    private func removeListListeners() {
        if toPlayListListenerAdd != nil {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
        } else {
            shouldRemoveToPlayListListenerAdd += 1
        }
        
        if playedListListenerAdd != nil {
            playedListListenerAdd!.removeListener()
            playedListListenerAdd = nil
        } else {
            shouldRemovePlayedListListenerAdd += 1
        }
        
        if toPlayListListenerRemove != nil {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
        } else {
            shouldRemoveToPlayListListenerRemove += 1
        }
        
        if playedListListenerRemove != nil {
            playedListListenerRemove!.removeListener()
            playedListListenerRemove = nil
        } else {
            shouldRemovePlayedListListenerRemove += 1
        }
    }
    
    private func listenToToPlayListAdd() {
        listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .add) { game in
            if self.toPlayList.add(game) {
                self.tableView.reloadData()
            }
            print("set content newest releases")
        }
    }
    
    private func listenToPlayedListAdd() {
        listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .add) { game in
            if self.playedList.add(game) {
                self.tableView.reloadData()
            }
            print("set content newest releases")
        }
    }
    
    private func listenToToPlayListRemove() {
        listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: .remove) { game in
            self.toPlayList.remove(game)
            self.tableView.reloadData()
            print("set content newest releases")
        }
    }
    
    private func listenToPlayedListRemove() {
        listenToList(ListsEndpoints.List.PLAYED_LIST, withAction: .remove) { game in
            self.playedList.remove(game)
            self.tableView.reloadData()
            print("set content newest releases")
        }
    }

    private func listenToList(_ list: String, withAction action: ListsListenerAction, withOnChange onChange: @escaping (Game)->()) {
        ListsList.instance.listenToList(list, withAction: action, withListenerAttached: { result in
            switch result {
            case .succes(let ref):
                self.listListenerAttachmentSuccesful(list, withAction: action, forReference: ref)
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        }, withOnChange: { result in
            switch result {
            case .succes(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        })
    }
    
    private func listListenerAttachmentSuccesful(_ list: String, withAction action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            if list == ListsEndpoints.List.TO_PLAY_LIST {
                self.toPlayListListenerAdd = ref
                if self.shouldRemoveToPlayListListenerAdd > 0 {
                    self.toPlayListListenerAdd!.removeListener()
                    self.toPlayListListenerAdd = nil
                    self.shouldRemoveToPlayListListenerAdd -= 1
                }
            } else if list == ListsEndpoints.List.PLAYED_LIST {
                self.playedListListenerAdd = ref
                if self.shouldRemovePlayedListListenerAdd > 0 {
                    self.playedListListenerAdd!.removeListener()
                    self.playedListListenerAdd = nil
                    self.shouldRemovePlayedListListenerAdd -= 1
                }
            }
        case .remove:
            if list == ListsEndpoints.List.TO_PLAY_LIST {
                self.toPlayListListenerRemove = ref
                if self.shouldRemoveToPlayListListenerRemove > 0 {
                    self.toPlayListListenerRemove!.removeListener()
                    self.toPlayListListenerRemove = nil
                    self.shouldRemoveToPlayListListenerRemove -= 1
                }
            } else if list == ListsEndpoints.List.PLAYED_LIST {
                self.playedListListenerRemove = ref
                if self.shouldRemovePlayedListListenerRemove > 0 {
                    self.playedListListenerRemove!.removeListener()
                    self.playedListListenerRemove = nil
                    self.shouldRemovePlayedListListenerRemove -= 1
                }
            }
        }
    }
    
    private func getStarState(_ game: Game) -> StarState {
        if toPlayList.contains(game) {
            return .toPlay
        } else if playedList.contains(game) {
            return .played
        } else {
            return .none
        }
    }
    
    private func shouldSwipeOnCells() -> Bool {
        return ListsUser.loggedIn
    }
        
    @objc private func refresh(_ sender: AnyObject) {
        reloadGames()
    }
    
    func initialLoadGames() {
        IGDB.instance.getGamesList({ result in
            self.handleLoadingGames(fromResult: result, withResultPacker: self.initialLoadGamesResultPacker)
        }, withLimit: paginationLimit)
    }
    
    private func initialLoadGamesResultPacker(_ games: [Game]) {
        _gameSections = GameSection.buildGameSectionsForNewestGames(fromGames: games)
        paginationOffset = 0
        loadingAnimationView.stopAnimating()
        animateTableViewAppearance()
    }
    
    private func animateTableViewAppearance() {
        tableView.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: {
            self.tableView.alpha = 1.0
        })
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
            let game = _gameSections[indexPath.section].games[indexPath.row]
            if game != cell.game {
                cell.update(game)
            }
            cell.updateStar(getStarState(game))
            cell.updateSwipeable(shouldSwipeOnCells())
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(25.0)
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
}






