//
//  SubListVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 17..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SubListVC: UIViewController, IdentifiableVC, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ErrorHandlerDelegate, UIGestureRecognizerDelegate {

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
    
    var loadingAnimationView: NVActivityIndicatorView?
    var appeared = false
    
    var panRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        setupDelegates()
        setupPanRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        setupLoadingAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !appeared {
            loadingAnimationView?.startAnimating()
        }
        appeared = true
    }
    
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupPanRecognizer() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SubListVC.handlePan(_:)))
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    private func setupLoadingAnimation() {
        let width: CGFloat = 80.0
        let height: CGFloat = width
        
        let x = view.bounds.size.width / 2.0 - width / 2.0
        let y = view.bounds.size.height / 2.0 - height / 2.0 - 50.0
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.MyCustomColors.orange, padding: 0.0)
        view.addSubview(loadingAnimationView!)
        loadingAnimationView!.stopAnimating()
    }
    
    private var panStartPoint: CGPoint?
    
    @objc func handlePan(_ recognizer: UIGestureRecognizer?) {
        guard let recognizer = recognizer as? UIPanGestureRecognizer else {
            return
        }
        switch recognizer.state {
        case .began:
            panStartPoint = recognizer.location(in: collectionView)
        case .changed:
            if var start = panStartPoint, let indexPath = collectionView.indexPathForItem(at: start), let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionViewCell {
                start = view.convert(start, to: cell)
                let loc = recognizer.location(in: cell)
                cell.panChanged(loc, fromStartingPoint: start)
            }
        case .ended:
            if let loc = panStartPoint, let indexPath = collectionView.indexPathForItem(at: loc), let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionViewCell {
                cell.panEnded()
                panStartPoint = nil
            }
        default:
            break
        }
    }
    
    func swapToListEmptyLabels() {
        animateCollectionViewDisappearance()
        animateListEmptyLabelsAppearance()
    }
    
    func swapToCollectionView() {
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
        cellWidth = collectionViewWidth / CELLS_PER_COLUMNS
        cellWidth -= (CELLS_PER_COLUMNS-1) * cellInterItemMargin
        cellWidth -= (2.0 * cellInsetMargin) / CELLS_PER_COLUMNS
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
    
    // Make sure to override these 2 methods with specific list typed cell and count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            if let rec = gestureRecognizer as? UIPanGestureRecognizer {
                if abs(rec.velocity(in: collectionView).x) > abs(rec.velocity(in: collectionView).y) {
                    return true
                }
            }
        }
        return false
    }
}








