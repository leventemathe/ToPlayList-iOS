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
        
        IGDB.instance.getNewestGamesList { result in
            switch result {
            case .succes(let games):
                self.games.append(contentsOf: games)
            case .failure(let error):
                switch error {
                case .serverError, .urlError, .jsonError:
                    self.presentNetworkingError(with: "There was an error with the server, please check back later!")
                case .noInternetError:
                    self.presentNetworkingError(with: "No internet connection!")
                }
            }
        }
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

