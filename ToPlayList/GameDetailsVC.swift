//
//  GameDetailsVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 10..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class GameDetailsVC: UIViewController {
    
    static let MISSING_GENRE_DATA = "No genre data"
    static let MISSING_DEVELOPER_DATA = "No developer data"
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    
    var game: Game?
    
    override func viewDidLoad() {
        addCustomBackButton()
        addGameDataAlreadyDownloaded()
    }
    
    private func addGameDataAlreadyDownloaded() {
        if let game = game {
            titleLbl.text = game.name
            genreLabel.text = game.genre?.description ?? GameDetailsVC.MISSING_GENRE_DATA
            developerLabel.text = game.developer?.description ?? GameDetailsVC.MISSING_DEVELOPER_DATA
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        makeNavbarTransparent()
    }
    
    private func addCustomBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_button"), style: .plain, target: self, action: #selector(GameDetailsVC.back(sender:)))

        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        resetNavbar()
    }
    
    private func makeNavbarTransparent() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func resetNavbar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
}
