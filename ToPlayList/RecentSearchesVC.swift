//
//  RecentSearchesVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 19..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class RecentSearchesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var strings = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var clearButtonClickedDelegate: (()->())?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func clearButtonClicked(_ sender: UIButton) {
        strings = [String]()
        clearButtonClickedDelegate?()
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func isEmpty() -> Bool {
        return strings.count <= 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseIdentifier) as? SearchCell {
            cell.textLabel?.text = strings[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}
