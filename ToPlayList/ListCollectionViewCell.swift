//
//  ListCollectionViewCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell, ReusableView, DropShadowed {
    
    
    @IBOutlet weak var coverImg: UIImageView! {
        didSet {
            coverImg.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var star: UIImageView!
    
    override func awakeFromNib() {
        addDropShadow()
    }
    
    func update(_ game: Game) {
        titleLbl.text = game.name
        if let coverURL = game.coverSmallURL {
            coverImg.kf.setImage(with: coverURL, placeholder: #imageLiteral(resourceName: "img_missing"))
        } else {
            coverImg.image = #imageLiteral(resourceName: "img_missing")
        }
    }
}
