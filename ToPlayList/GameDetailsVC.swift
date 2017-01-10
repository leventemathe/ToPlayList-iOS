//
//  GameDetailsVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 10..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class GameDetailsVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    var game: Game?
    
    override func viewDidLoad() {
        if let game = game {
            titleLbl.text = game.name
        }
    }
}
