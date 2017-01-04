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
    
    private var games = [Game]() {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        IGDB.instance.getNewestGamesList { result in
            switch result {
            case .succes(let games):
                self.games = games
                self.resetListBackground()
            case .failure(let error):
                self.setListBackground()
                switch error {
                case .serverError, .urlError, .jsonError:
                    self.presentNetworkingError(with: "There was an error with the server, please check back later!")
                    break
                case .noInternetError:
                    self.presentNetworkingError(with: "No internet connection!")
                    break
                }
            }
            self.refreshVC.endRefreshing()
        }
    }

    //TODO move to TableViewDelegates with delegate methods
    private func setListBackground() {
        if(games.count > 0) {
            return
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundView = noDataLbl
    }
    
    private func resetListBackground() {
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }

    private func presentNetworkingError(with message: String) {
        let alert = UIAlertController(title: "Error 😟", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewestReleasesCell.reuseIdentifier, for: indexPath) as? NewestReleasesCell {
            let game = games[indexPath.row]
            cell.update(game)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
}






