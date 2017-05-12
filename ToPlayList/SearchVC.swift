//
//  SearchVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        stepIn()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stepOut()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        stepOut()
    }
    
    private func stepOut() {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    private func stepIn() {
        searchBar.showsCancelButton = true
    }
}
