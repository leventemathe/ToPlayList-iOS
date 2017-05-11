//
//  BadgeVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class BadgeVC: UIViewController, UICollectionViewDataSource, IdentifiableVC, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var constraintsSetDelegate: CollectionViewSizeDidSetDelegate?
    
    private var strings = [String]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    func add(string: String) {
        strings.append(string)
    }
    
    func add(strings: [String]) {
        self.strings.append(contentsOf: strings)
    }
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return strings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let badgeCell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCell.reuseIdentifier, for: indexPath) as? BadgeCell {
            badgeCell.update(strings[indexPath.row])
            return badgeCell
        }
        return UICollectionViewCell()
    }
    
    private let CELLS_PER_COLUMN: CGFloat = 3.0
    private let CELL_HEIGHT: CGFloat = 30.0
    private var collectionViewWidth: CGFloat!
    private var cellWidth: CGFloat!
    private var cellHorizontalInterItemMargin: CGFloat!
    private var cellVerticalInterItemMargin: CGFloat!
    
    private func setupCellMargins() {
        collectionViewWidth = collectionView?.frame.size.width ?? UIScreen.main.bounds.size.width
        cellHorizontalInterItemMargin = 8.0 / 2.0
        cellVerticalInterItemMargin = cellHorizontalInterItemMargin * 2.0
    }
    
    private func setupCellSize() {
        cellWidth = collectionViewWidth / CELLS_PER_COLUMN - (CELLS_PER_COLUMN-1.0) * cellHorizontalInterItemMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        setupCellMargins()
        setupCellSize()
        
        constraintsSetDelegate?.didSetSize(numberOfItems: strings.count, numberOfRows: Int(ceil(CGFloat(strings.count) / CELLS_PER_COLUMN)), sizeOfItems: CGSize(width: cellWidth, height: CELL_HEIGHT), sizeOfMargins: CGSize(width: cellHorizontalInterItemMargin, height: cellVerticalInterItemMargin))
        
        return CGSize(width: cellWidth, height: CELL_HEIGHT)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        setupCellMargins()
        return cellHorizontalInterItemMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        setupCellMargins()
        return cellVerticalInterItemMargin
    }
}
