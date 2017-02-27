//
//  ToPlayListVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ToPlayListVC: UIViewController, IdentifiableVC, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
 
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let CELLS_PER_COLUMNS: CGFloat = 2.0
    private let CELL_ASPECT_RATIO: CGFloat = 1.42
    private var collectionViewWidth: CGFloat!
    private var cellWidth: CGFloat!
    private var cellHeight: CGFloat!
    private var cellInsetMargin: CGFloat!
    private var cellInterItemMargin: CGFloat!
    private var cellVerticalInterItemMargin: CGFloat!
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST) {
        didSet {
            collectionView.reloadData()
            print("reloading collection view becasue didSet")
        }
    }
    
    override func viewDidLoad() {
        setupDelegates()
        getToPlayList()
    }
    
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        setupCellSizes()
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        setupCellSizes()
        return UIEdgeInsets(top: cellInsetMargin, left: cellInsetMargin, bottom: cellInsetMargin, right: cellInsetMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        setupCellSizes()
        return cellInterItemMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellVerticalInterItemMargin
    }
    
    private func setupCellSizes() {
        collectionViewWidth = collectionView.bounds.size.width
        cellInsetMargin = 20.0
        cellInterItemMargin = (cellInsetMargin + 10.0) / 2.0
        cellVerticalInterItemMargin = cellInterItemMargin * 2.0
        cellWidth = collectionViewWidth / CELLS_PER_COLUMNS - (CELLS_PER_COLUMNS-1) * cellInterItemMargin - (2.0 * cellInsetMargin) / CELLS_PER_COLUMNS
        cellHeight = cellWidth * CELL_ASPECT_RATIO
    }
}
