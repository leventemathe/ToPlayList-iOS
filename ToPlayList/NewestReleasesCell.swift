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
    @IBOutlet weak var star: UIImageView!
    
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
        if User.loggedIn {
            star.isHidden = false
        } else {
            star.isHidden = true
        }
    }
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var toPlay: UILabel!
    @IBOutlet weak var played: UILabel!
    
    @IBOutlet weak var contentLeading: NSLayoutConstraint!
    @IBOutlet weak var contentTrailing: NSLayoutConstraint!
    @IBOutlet weak var contentTop: NSLayoutConstraint!
    @IBOutlet weak var contentBottom: NSLayoutConstraint!
    
}









