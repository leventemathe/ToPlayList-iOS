//
//  ToPlayListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ToPLayListVC: UIViewController, IdentifiableVC, UICollectionViewDelegate, UICollectionViewDataSource {
 
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST) {
        didSet {
            collectionView.reloadData()
            print("reloading collection view becasue didSet")
        }
    }
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        getToPlayList()
    }
    
    private func getToPlayList() {
        ListsList.instance.getToPlayList { result in
            switch result {
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            case .succes(let list):
                self.toPlayList = list
                print("dowloaded toPlayList")
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toPlayList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.reuseIdentifier, for: indexPath) as? ListCollectionViewCell {
            if let game = toPlayList[indexPath.row] {
                cell.update(game)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
