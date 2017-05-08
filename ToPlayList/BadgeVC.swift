//
//  BadgeVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class BadgeVC: UICollectionViewController, IdentifiableVC {

    private var strings = [String]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    func add(string: String) {
        strings.append(string)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return strings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let badgeCell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCell.reuseIdentifier, for: indexPath) as? BadgeCell {
            badgeCell.update(strings[indexPath.row])
            return badgeCell
        }
        return UICollectionViewCell()
    }
    
    //TODO sizing methods here
}
