//
//  NewestReleasesCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit

class NewestReleasesCell: UITableViewCell, ReusableView {

    @IBOutlet weak var coverView: ListImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!

    override public func awakeFromNib() {
        super.awakeFromNib()
        coverView.addRoundedCorners()
    }
    
    func update(_ game: Game) {
        titleLabel.text = game.name
        if let coverURL = game.coverURL {
            coverView.kf.setImage(with: coverURL, placeholder: #imageLiteral(resourceName: "img_missing"))
        } else {
            coverView.image = #imageLiteral(resourceName: "img_missing")
        }
        if let genre = game.genre {
            genreLabel.text = genre.name
        }
        if let developer = game.developer {
            developerLabel.text = developer.name
        }
    }
}
