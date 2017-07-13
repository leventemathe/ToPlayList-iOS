//
//  ImageCarouselVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ImageCarouselVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    typealias ImageURLPairs = [(small: URL, big: URL)]
    
    // TODO add large urls too, and add loading of large images if small failed, when dequeing cell
    private var imageURLs = ImageURLPairs() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    func addImages(from game: Game) {
        guard let smallURLs = game.screenshotSmallURLs, let bigURLs = game.screenshotBigURLs else {
            return
        }
        if smallURLs.count != bigURLs.count {
            return
        }
        var newUrls = ImageURLPairs()
        for i in 0..<smallURLs.count {
            let smallURL = smallURLs[i]
            let bigURL = bigURLs[i]
            let urlPair = (small: smallURL, big: bigURL)
            if !imageURLs.contains(where: {small, big in
                return small == urlPair.small && big == urlPair.big
            }) {
                newUrls.append(urlPair)
            }
        }
        imageURLs.append(contentsOf: newUrls)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCarouselCell.reuseIdentifier, for: indexPath) as? ImageCarouselCell {
            cell.update(imageURLs[indexPath.row].small)
            return cell
        }
        return UICollectionViewCell()
    }
    
    // SIZING
    
    private var cellWidth: CGFloat!
    private var cellHeight: CGFloat!
    private let CELL_ASPECT_RATIO: CGFloat = 570.0 / 320.0
    private let NUM_OF_VISIBLE_CELLS: CGFloat = 2.5
    private var collectionViewWidth: CGFloat!
    private var cellHorizontalInterItemMargin: CGFloat! = 8.0 / 2.0
    
    private func setupCellSizes() {
        collectionViewWidth = collectionView?.frame.size.width ?? UIScreen.main.bounds.size.width
        cellWidth = collectionViewWidth / NUM_OF_VISIBLE_CELLS - (NUM_OF_VISIBLE_CELLS - 1) * cellHorizontalInterItemMargin
        cellHeight = cellWidth / CELL_ASPECT_RATIO
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        setupCellSizes()
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        setupCellSizes()
        return cellHorizontalInterItemMargin
    }
}
