//
//  ListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ListVC: UIViewController, IdentifiableVC, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private static let WELCOME_MSG = "Welcome"
    
    private var _games = [Game]()

    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
    
    }
    
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        
        // TODO are you sure you want to log out
        
        do {
            try FIRAuth.auth()?.signOut()
            _ = navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            // TODO error handling
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
        setupWelcomeMsg()
    }
    
    func setupWelcomeMsg() {
        welcomeLbl.text = "\(ListVC.WELCOME_MSG)!"
        LISTS_DB_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any], let username = value["username"] as? String {
                self.welcomeLbl.text = "\(ListVC.WELCOME_MSG) \(username)!"
            }
        })
    }
    
    override func viewDidLoad() {
        //TODO download games from firebase into array
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.reuseIdentifier, for: indexPath) as? ListCollectionViewCell {
            cell.update(_games[indexPath.row])
            return cell
        }
        return ListCollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
