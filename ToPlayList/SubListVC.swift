//
//  SubListVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 17..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class SubListVC: UIViewController, IdentifiableVC, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ErrorHandlerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var listEmptyLabels: UIStackView!
    
    private let CELLS_PER_COLUMNS: CGFloat = 2.0
    private let CELL_ASPECT_RATIO: CGFloat = 1.42
    private let CELL_TITLE_HEIGHT: CGFloat = 30.0
    private var collectionViewWidth: CGFloat!
    private var cellWidth: CGFloat!
    private var cellHeight: CGFloat!
    private var cellInsetMargin: CGFloat!
    private var cellInterItemMargin: CGFloat!
    private var cellVerticalInterItemMargin: CGFloat!
    
    var loadingAnimationDelegate: LoadingAnimationDelegate?
    
    override func viewDidLoad() {
        setupDelegates()
    }
    
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func swapToListEmptyLabels() {
        //print("swapping to list empty")
        animateCollectionViewDisappearance()
        animateListEmptyLabelsAppearance()
    }
    
    func swapToCollectionView() {
        //print("swapping to collection view")
        animateListEmptyLabelsDisappearance()
        animateCollectionViewAppearance()
    }
    
    private func animateListEmptyLabelsAppearance() {
        listEmptyLabels.isHidden = false
        listEmptyLabels.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: {
            self.listEmptyLabels.alpha = 1.0
        })
    }
    
    private func animateCollectionViewAppearance() {
        collectionView.isHidden = false
        collectionView.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: {
            self.collectionView.alpha = 1.0
        })
    }
    
    private func animateListEmptyLabelsDisappearance() {
        UIView.animate(withDuration: 0.4, animations: {
            self.listEmptyLabels.alpha = 0.0
        }, completion: { success in
            if success {
                self.listEmptyLabels.isHidden = true
            }
        })
    }
    
    private func animateCollectionViewDisappearance() {
        UIView.animate(withDuration: 3.0, animations: {
            self.collectionView.alpha = 0.0
        }, completion: { success in
            if success {
                self.collectionView.isHidden = true
            }
        })
    }
    
    func handleError(_ message: String) {
        Alerts.alertWithOKButton(withMessage: message, forVC: self)
    }
    
    private func setupCellSizes() {
        collectionViewWidth = collectionView.bounds.size.width
        cellInsetMargin = 20.0
        cellInterItemMargin = (cellInsetMargin + 10.0) / 2.0
        cellVerticalInterItemMargin = cellInterItemMargin * 2.0
        cellWidth = collectionViewWidth / CELLS_PER_COLUMNS - (CELLS_PER_COLUMNS-1) * cellInterItemMargin - (2.0 * cellInsetMargin) / CELLS_PER_COLUMNS
        cellHeight = cellWidth * CELL_ASPECT_RATIO + CELL_TITLE_HEIGHT
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Make sure to override these with specific list typed cell and count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
