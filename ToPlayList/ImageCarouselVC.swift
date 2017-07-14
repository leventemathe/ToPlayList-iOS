//
//  ImageCarouselVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import ImageViewer
import Kingfisher

enum CarouselContentType {
    case image
    case video
}

class AbstractCarouselContent {
    
}

class ImageCarouselContent: AbstractCarouselContent {
    
    var small: URL
    var big: URL
    
    init(smallURL: URL, bigURL: URL) {
        small = smallURL
        big = bigURL
    }
}

class VideoCarouselContent: AbstractCarouselContent {
    
    var thumbnail: URL
    var video: URL
    
    init(thumbnailURL: URL, videoURL: URL) {
        thumbnail = thumbnailURL
        video = videoURL
    }
}

struct CarouselContentContainer {
    
    let type: CarouselContentType
    let content: AbstractCarouselContent
}

class ImageCarouselVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GalleryItemsDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var imageLoadErrorDelegate: ErrorHandlerDelegate?
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    typealias ImageURLPairs = [(small: URL, big: URL)]
    
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
            cell.update(imageURLs[indexPath.row].small, withOnComplete: { result in
                if !result {
                    self.imageLoadErrorDelegate?.handleError()
                }
            })
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentImageGallery(GalleryViewController(startIndex: indexPath.row, itemsDataSource: self, configuration: [.deleteButtonMode(.none), .pagingMode(.carousel), .thumbnailsButtonMode(.none)]))
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
    
    // GALLERY
    func itemCount() -> Int {
        return imageURLs.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return GalleryItem.image(fetchImageBlock: { onComplete in
            KingfisherManager.shared.retrieveImage(with: self.imageURLs[index].big, options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                if error == nil {
                    onComplete(image)
                } else {
                    print(error!)
                    KingfisherManager.shared.retrieveImage(with: self.imageURLs[index].small, options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                        // this doesn't seem to throw error if image is nil, the loading anim continues to spin
                        // but it's pretty safe, because small is guaranteed to exist: the image carousel wouldn't be visible otherwise
                        onComplete(image)
                    })
                }
            })
        })
    }
}

