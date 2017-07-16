//
//  ReleaseDateVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 16..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ReleaseDateVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var didSetHeightDelegate: DidSetHeightDelegate?
    
    var releaseDates = [ReleaseDate]() {
        didSet {
            releaseDates.sort(by: { $0.date > $1.date })
            tableView.reloadData()
            didSetHeightDelegate?.didSet(height: CGFloat(releaseDates.count) * tableView.rowHeight)
        }
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return releaseDates.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReleaseDateCell.reuseIdentifier) as? ReleaseDateCell {
            cell.update(releaseDates[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}
