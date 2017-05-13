//
//  SearchVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var api: GameAPI = IGDB.instance
    
    var games = [Game]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        setupSearchBar()
        setupTableView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.setImage(#imageLiteral(resourceName: "clear_default"), for: .clear, state: .normal)
        searchBar.setImage(#imageLiteral(resourceName: "clear_default"), for: .clear, state: .highlighted)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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
        }
        stepOut()
    }
    
    private func search(_ string: String) {
        api.getGames(bySearchString: string, withLimit: 10, withOnComplete: { result in
            switch result {
            case .success(let games):
                self.games = games
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
