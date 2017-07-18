//
//  ReleaseDateCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 16..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ReleaseDateCell: UITableViewCell, ReusableView {
    
    @IBOutlet weak var platformLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    func update(_ releaseDate: ReleaseDate) {
        dateLbl.text = Dates.dateFromUnixTimeFull(releaseDate.date)
        platformLbl.text = releaseDate.platform.getShorterVersion()
    }
}
