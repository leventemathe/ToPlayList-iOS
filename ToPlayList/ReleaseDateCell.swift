//
//  ReleaseDateCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 16..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ReleaseDateCell: UITableViewCell, ReusableView {
    
    @IBOutlet weak var platformImg: UIImageView!
    @IBOutlet weak var platformLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    func update(_ releaseDate: ReleaseDate) {
        dateLbl.text = Dates.dateFromUnixTime(releaseDate.date)
        // TODO try image; if it doesn't exist, use text
        platformLbl.text = releaseDate.platform.name
    }
}
