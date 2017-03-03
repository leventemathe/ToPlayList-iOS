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
    @IBOutlet weak var listEmptyLabels: UIStackView!
    
    private let CELLS_PER_COLUMNS: CGFloat = 2.0
    private let CELL_ASPECT_RATIO: CGFloat = 1.42
    private var collectionViewWidth: CGFloat!
    private var cellWidth: CGFloat!
    private var cellHeight: CGFloat!
    private var cellInsetMargin: CGFloat!
    private var cellInterItemMargin: CGFloat!
    private var cellVerticalInterItemMargin: CGFloat!
    
    var loadingAnimationDelegate: LoadingAnimationDelegate?
    
    private var toPlayList = List(ListsEndpoints.List.TO_PLAY_LIST)
    
    private var toPlayListListenerAdd: ListsListenerReference?
    private var toPlayListListenerRemove: ListsListenerReference?
    
    private var shouldRemoveToPlayListListenerAdd = 0
    private var shouldRemoveToPlayListListenerRemove = 0
    
    override func viewDidLoad() {
        setupDelegates()
    }
    
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("view will appear")
        getToPlayList {
            self.attachListeners()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("view did disappear")
        removeListeners()
    }
    
    private func attachListeners() {
        //print("attaching listeners")
        listenToToPlayList(.add, withOnChange: { game in
            if self.toPlayList.add(game) {
                self.setContent()
            }
        })
        listenToToPlayList(.remove, withOnChange: { game in
            self.toPlayList.remove(game)
            self.setContent()
        })
    }
    
    private func listenToToPlayList(_ action: ListsListenerAction, withOnChange onChange: @escaping (Game)->()) {
        ListsList.instance.listenToList(ListsEndpoints.List.TO_PLAY_LIST, withAction: action, withListenerAttached: { result in
            switch result {
            case .succes(let ref):
                self.listListenerAttachmentSuccesful(action, forReference: ref)
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        }, withOnChange: { result in
            switch result {
            case .succes(let game):
                onChange(game)
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            }
        })
    }
    
    private func listListenerAttachmentSuccesful(_ action: ListsListenerAction, forReference ref: ListsListenerReference) {
        switch action {
        case .add:
            self.toPlayListListenerAdd = ref
            self.removeLateToPlayListListenerAdd()
        case .remove:
            self.toPlayListListenerRemove = ref
            self.removeLatePlayedListListenerRemove()
        }
    }
    
    private func removeLateToPlayListListenerAdd() {
        if shouldRemoveToPlayListListenerAdd > 0 {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
            shouldRemoveToPlayListListenerAdd -= 1
        }
    }
    
    private func removeLatePlayedListListenerRemove() {
        if shouldRemoveToPlayListListenerRemove > 0 {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
            shouldRemoveToPlayListListenerRemove -= 1
        }
    }
    
    private func removeListeners() {
        //print("removing listeners")
        removeToPlayListListenerAdd()
        removeToPlayListListenerRemove()
    }
    
    private func removeToPlayListListenerAdd() {
        if toPlayListListenerAdd != nil {
            toPlayListListenerAdd!.removeListener()
            toPlayListListenerAdd = nil
        } else {
            shouldRemoveToPlayListListenerAdd += 1
        }
    }
    
    private func removeToPlayListListenerRemove() {
        if toPlayListListenerRemove != nil {
            toPlayListListenerRemove!.removeListener()
            toPlayListListenerRemove = nil
        } else {
            shouldRemoveToPlayListListenerRemove += 1
        }
    }
    
    private func getToPlayList(_ onComplete: @escaping ()->()) {
        ListsList.instance.getToPlayList { result in
            self.loadingAnimationDelegate?.stopAnimating()
            
            switch result {
            case .failure(let error):
                switch error {
                default:
                    Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
                }
            case .succes(let list):
                self.toPlayList = list
            }
            self.setContent()
            onComplete()
        }
    }
    
    private var listWasEmptyLastTime: Bool?
    
    private func setContent() {
        print("set content in toPlay list")
        collectionView.reloadData()
        if toPlayList.count < 1 {
            if listWasEmptyLastTime == nil || !listWasEmptyLastTime!{
                swapToListEmptyLabels()
            }
            listWasEmptyLastTime = true
        } else {
            if listWasEmptyLastTime == nil || listWasEmptyLastTime! {
                swapToCollectionView()
            }
            listWasEmptyLastTime = false
        }
    }
    
    private func swapToListEmptyLabels() {
        //print("swapping to list empty")
        animateCollectionViewDisappearance()
        animateListEmptyLabelsAppearance()
    }
    
    private func swapToCollectionView() {
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
