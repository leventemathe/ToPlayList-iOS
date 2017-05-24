//
//  ImageCarouselVCViewController.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ImageCarouselVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private var imageURLs = [URL]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    func addImage(byUrl url: URL) {
        if !imageURLs.contains(url) {
            imageURLs.append(url)
        }
    }
    
    func addImages(byUrls urls: [URL]) {
        var newUrls = [URL]()
        for url in urls {
            if !imageURLs.contains(url) {
                newUrls.append(url)
            }
        }
        imageURLs.append(contentsOf: newUrls)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCarouselCell.reuseIdentifier, for: indexPath) as? ImageCarouselCell {
            cell.update(imageURLs[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}
