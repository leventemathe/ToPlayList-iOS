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
import Firebase

class ReleasesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorHandlerDelegate, UIGestureRecognizerDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerAd: GADBannerView!
    @IBOutlet weak var adContainer: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    private var noDataLbl = UILabel()
    private var loadingAnimationView: NVActivityIndicatorView!
    private var refreshVC = UIRefreshControl()
    
    private var loadingMoreGames = true
    private var noInternetAlertAppearedForScrolling = false
    
    var gameSections = [GameSection]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let paginationLimit = 30
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
        setupBannerAd()
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
        noDataLbl.text = "No data. Pull to refresh."
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
    
    var panRecognizer: UIPanGestureRecognizer!
    var panStartPoint: CGPoint?
    
    private func setupPanRecognizer() {
        if ListsUser.loggedIn && ListsUser.verified {
            if panRecognizer == nil {
                panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ReleasesVC.handlePan(_:)))
                view.addGestureRecognizer(panRecognizer)
            }
        } else {
            if panRecognizer != nil {
                view.removeGestureRecognizer(panRecognizer)
                panRecognizer = nil
            }
        }
    }
    
    @objc func handlePan(_ recognizer: UIGestureRecognizer?) {
        guard let recognizer = recognizer as? UIPanGestureRecognizer else {
            return
        }
        switch recognizer.state {
        case .began:
            panStartPoint = recognizer.location(in: tableView)
        case .changed:
            if var start = panStartPoint, let indexPath = tableView.indexPathForRow(at: start), let cell = tableView.cellForRow(at: indexPath) as? ReleasesCell {
                start = view.convert(start, to: cell)
                let loc = recognizer.location(in: cell)
                cell.panChanged(loc, fromStartingPoint: start)
            }
        case .ended:
            if let loc = panStartPoint, let indexPath = tableView.indexPathForRow(at: loc), let cell = tableView.cellForRow(at: indexPath) as? ReleasesCell {
                cell.panEnded()
                panStartPoint = nil
            }
        default:
            break
        }
    }
    
    private func setupBannerAd() {
        if !Configuration.instance.admob.enabled {
            return
        }
        bannerAd.adUnitID = Configuration.instance.admob.releasesAdUnitID
        
        bannerAd.rootViewController = self
        adContainer.isHidden = true
        bannerAd.delegate = self
        
        let request = GADRequest()
        bannerAd.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        adContainer.isHidden = false
        tableViewBottomConstraint.constant = bannerAd.frame.size.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noInternetAlertAppearedForScrolling = false
        setupPanRecognizer()
        clearStars()
        if ListsUser.loggedIn && ListsUser.verified {
            getGamesInLists {
                self.attachListListeners()
            }
        }
    }
    
    private func clearStars() {
        toPlayList.clear()
        playedList.clear()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("\(self): detached listener")
        self.listsListenerSystem.detachListeners()
    }
    
    private func getGamesInLists(_ onComplete: @escaping ()->()) {
        if !(ListsUser.loggedIn && ListsUser.verified) {
            return
        }
        ListsList.instance.getToPlayAndPlayedList { result in
            switch result {
            case .failure:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            case .success(let lists):
                self.toPlayList.add(lists.toPlay)
                self.playedList.add(lists.played)
            }
            self.tableView.reloadData()
            onComplete()
        }
    }
    
    private func attachListListeners() {
        //print("\(self): attached listener")
        
        if !(ListsUser.loggedIn && ListsUser.verified) {
            return
        }
        listsListenerSystem.attachListeners(withOnAddedToToPlayList: { game in
            if self.toPlayList.add(game) {
                self.tableView.reloadData()
            }
        }, withOnRemovedFromToPlayList: { game in
            self.toPlayList.remove(game)
            self.tableView.reloadData()
        }, withOnAddedToPlayedList: { game in
            if self.playedList.add(game) {
                self.tableView.reloadData()
            }
        }, withOnRemovedFromPlayedList: { game in
            self.playedList.remove(game)
            self.tableView.reloadData()
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
    
    enum GameLoadingLocation {
        case reload
        case loadMore
    }
    
    func handleLoadingGames(fromResult result: IGDBResult<[Game]>, fromLocation location: GameLoadingLocation, withResultPacker packer: ([Game])->Void) {
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
                switch location {
                case .reload:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .loadMore:
                    if !noInternetAlertAppearedForScrolling {
                        Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                    }
                    noInternetAlertAppearedForScrolling = true
                }
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
            cell.loggedIn = ListsUser.loggedIn && ListsUser.verified
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
        if loadingMoreGames || gameSections.count < 1 {
            return
        }
        let position = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        
        if position > height - scrollView.frame.size.height * 1.5 {
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
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            if let rec = gestureRecognizer as? UIPanGestureRecognizer {
                if abs(rec.velocity(in: tableView).x) > abs(rec.velocity(in: tableView).y) {
                    return true
                }
            }
        }
        return false
    }
}






