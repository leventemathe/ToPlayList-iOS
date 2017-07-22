//
//  ReleasesVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView

class ReleasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorHandlerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var noDataLbl = UILabel()
    private var loadingAnimationView: NVActivityIndicatorView!
    private var refreshVC = UIRefreshControl()
    
    private var loadingMoreGames = true
    
    var gameSections = [GameSection]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let paginationLimit = 10
    var paginationOffset = 0
    
    private var listsListenerSystem = ToPlayAndPlayedListListeners()
    
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
        
        listsListenerSystem.errorHandlerDelegate = self
    }
    
    private func setupNoDataLabel() {
        noDataLbl.bounds = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: tableView.bounds.height)
        noDataLbl.text = "No data. Pull to refresh!"
        noDataLbl.font = UIFont.MyFonts.avenirDefault(size: 22)!
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
    
    private var loggedIn = false {
        didSet {
            tableView.reloadData()
            if loggedIn && !listsListenerSystem.isAttached() {
                getGamesInLists {
                    self.attachListListeners()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearStars()
        ListsUser.instance.listenToLoggedInState(onChange: { (userid, loggedIn) in
            self.loggedIn = loggedIn
        })
    }
    
    private func clearStars() {
        toPlayList.clear()
        playedList.clear()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.listsListenerSystem.detachListeners()
        ListsUser.instance.stopListeningToLoggedInState()
    }
    
    private func getGamesInLists(_ onComplete: @escaping ()->()) {
        ListsList.instance.getToPlayAndPlayedList { result in
            switch result {
            case .failure:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            case .succes(let lists):
                self.toPlayList.add(lists.toPlay)
                self.playedList.add(lists.played)
            }
            self.tableView.reloadData()
            onComplete()
        }
    }
    
    private func attachListListeners() {
        listsListenerSystem.attachListeners(withOnAddedToToPlayList: { game in
            if self.toPlayList.add(game) {
                self.tableView.reloadData()
                print("set content newest releases")
            }
        }, withOnRemovedFromToPlayList: { game in
            self.toPlayList.remove(game)
            self.tableView.reloadData()
            print("set content newest releases")
        }, withOnAddedToPlayedList: { game in
            if self.playedList.add(game) {
                self.tableView.reloadData()
                print("set content newest releases")
            }
        }, withOnRemovedFromPlayedList: { game in
            self.playedList.remove(game)
            self.tableView.reloadData()
            print("set content newest releases")
        })
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
    
    @objc private func refresh(_ sender: AnyObject) {
        reloadGames()
    }
    
    // override these empty methods in newest and upcoming vcs
    func initialLoadGames() {}
    func loadMoreGames() {}
    func reloadGames() {}
    
    func initialLoadGamesResultPacker(_ games: [Game]) {}
    func relaodGamesResultPacker(_ games: [Game]) {}
    func loadMoreGamesResultPacker(_ games: [Game]) {}
    
    
    
    func animateTableViewAppearance() {
        tableView.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: {
            self.tableView.alpha = 1.0
        })
    }
    
    func handleLoadingGames(fromResult result: IGDBResult<[Game]>, withResultPacker packer: ([Game])->Void) {
        switch result {
        case .success(let games):
            packer(games)
            self.resetListBackground()
        case .failure(let error):
            self.setListBackground()
            switch error {
            case .server, .url, .json:
                Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
            case .noInternet:
                Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
            case .noData:
                break
            case .unknown:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_ERROR, forVC: self)
            }
        }
        loadingAnimationView.stopAnimating()
        self.refreshVC.endRefreshing()
        loadingMoreGames = false
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReleasesCell.reuseIdentifier, for: indexPath) as? ReleasesCell {
            cell.networkErrorHandlerDelegate = self
            let game = gameSections[indexPath.section].games[indexPath.row]
            if game != cell.game {
                cell.update(game)
            }
            cell.updateStar(getStarState(game))
            cell.loggedIn = loggedIn
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(25.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as! HeaderView
        headerView.label.text = gameSections[section].header
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameSections[section].games.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        
        if position > height - scrollView.frame.size.height * 1.5 && !loadingMoreGames && gameSections.count != 0 {
            loadingMoreGames = true
            loadMoreGames()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setCellScrollings(true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            setCellScrollings(false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCellScrollings(false)
    }
    
    private func setCellScrollings(_ to: Bool) {
        let cells = tableView.visibleCells
        for cell in cells {
            if let cell = cell as? ReleasesCell {
                cell.scrolling = to
            }
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





