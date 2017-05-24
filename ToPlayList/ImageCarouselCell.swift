//
//  ImageCarouselCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import Kingfisher

class ImageCarouselCell: UICollectionViewCell, ReusableView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func update(_ imageUrl: URL) {
        imageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "img_missing"))
    }
}
