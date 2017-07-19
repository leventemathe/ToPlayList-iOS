//
//  SearchVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SearchVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchIconView: UIView!
    @IBOutlet weak var recentSearchesView: UIView!
    private var recentSearchesVC: RecentSearchesVC!
    
    private let RECENT_SEARCH_KEY = "recent_searches"
    
    private var loadingAnimationView: NVActivityIndicatorView?
    
    private var api: GameAPI = IGDB.instance
    
    var games = [Game]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        // this prevents empty cells being shown
        tableView.tableFooterView = UIView()
        setupSearchBar()
        setupTableView()
        setupLoadingAnimation()
        setupRecentSearches()
        setupPlaceHolderViews()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.setImage(#imageLiteral(resourceName: "clear_default"), for: .clear, state: .normal)
        searchBar.setImage(#imageLiteral(resourceName: "clear_default"), for: .clear, state: .highlighted)
        setTextFieldTintColor(to: .lightGray, for: searchBar)
    }
    
    func setTextFieldTintColor(to color: UIColor, for view: UIView) {
        if view is UITextField {
            view.tintColor = color
        }
        for subview in view.subviews {
            setTextFieldTintColor(to: color, for: subview)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLoadingAnimation() {
        let width: CGFloat = 80.0
        let height: CGFloat = width
        
        let x = view.bounds.size.width / 2.0 - width / 2.0
        let y = view.bounds.size.height / 2.0 - height / 2.0 - 50.0
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.MyCustomColors.orange, padding: 0.0)
        view.addSubview(loadingAnimationView!)
        loadingAnimationView!.stopAnimating()
    }
    
    private func setupRecentSearches() {
        findRecentSearchesVC()
        setupRecentSearchesDelegate()
        setRecentSearches()
    }
    
    private func findRecentSearchesVC() {
        for vc in childViewControllers {
            if let rsVC = vc as? RecentSearchesVC {
                self.recentSearchesVC = rsVC
                break
            }
        }
    }
    
    private func setupRecentSearchesDelegate() {
        recentSearchesVC.clearButtonClickedDelegate = { [weak self] in
            self?.clearRecentSearches()
            self?.setupPlaceHolderViews()
        }
    }
    
    private func setRecentSearches() {
        let userDefaults = UserDefaults.standard
        if let strings = userDefaults.stringArray(forKey: RECENT_SEARCH_KEY) {
            recentSearchesVC.strings = strings
        }
    }
    
    private func setupPlaceHolderViews() {
        if recentSearchesVC.isEmpty() {
            recentSearchesView.isHidden = true
            searchIconView.isHidden = false
        } else {
            recentSearchesView.isHidden = false
            searchIconView.isHidden = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        stepIn()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stepOut()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let string = searchBar.text {
            let searchString = string.replacingOccurrences(of: " ", with: "+")
            search(searchString)
            storeSearch(string)
        }
        clearTableView()
        stepOut()
        resultWillAppear()
        loadingAnimationView?.startAnimating()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            resultWillDisappear()
            clearTableView()
        }
    }
    
    private func clearTableView() {
        games = [Game]()
    }
    
    private func search(_ string: String) {
        api.getGames(bySearchString: string, withLimit: 30, withOnComplete: { result in
            switch result {
            case .success(let games):
                self.games = games
                self.loadingAnimationView?.stopAnimating()
            case .failure(let error):
                switch error {
                case .json, .server, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_ERROR, forVC: self)
                }
            }
        })
    }
    
    private func stepOut() {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    private func stepIn() {
        searchBar.showsCancelButton = true
    }
    
    private func resultWillAppear() {
        recentSearchesView.isHidden = true
        searchIconView.isHidden = true
    }
    
    private func resultWillDisappear() {
        setRecentSearches()
        setupPlaceHolderViews()
    }
    
    private func storeSearch(_ string: String) {
        let userDefaults = UserDefaults.standard
        if var array = userDefaults.stringArray(forKey: RECENT_SEARCH_KEY) {
            if !array.contains(string) {
                array.append(string)
            }
            userDefaults.set(array, forKey: RECENT_SEARCH_KEY)
        } else {
            userDefaults.set([string], forKey: RECENT_SEARCH_KEY)
        }
    }
    
    private func clearRecentSearches() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: RECENT_SEARCH_KEY)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if games.count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier) as? SearchCell {
            cell.textLabel?.text = games[indexPath.row].name
            return cell
        }
        return UITableViewCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GameDetailsVC {
            if let i = tableView.indexPathForSelectedRow {
                let game = games[i.row]
                destinationVC.game = game
            }
        }
    }
}
