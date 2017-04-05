//
//  GameDetailsVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 10..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Kingfisher

class GameDetailsVC: UIViewController {
    
    typealias OnFinishedListener = () -> ()
    
    struct DetailsLoaded {
        
        static let COVER = "cover"
        static let BIG_SCREENSHOT = "bigScreenshot"
        
        private var listener: OnFinishedListener
        
        var loaded = [DetailsLoaded.COVER: false] {
                      //DetailsLoaded.BIG_SCREENSHOT: false] {
            didSet {
                if isFullyLoaded() {
                    listener()
                }
            }
        }
        
        init(_ onFinishedListener: @escaping OnFinishedListener) {
            listener = onFinishedListener
        }
        
        func isFullyLoaded() -> Bool {
            for (_, elem) in loaded {
                if !elem {
                    return false
                }
            }
            return true
        }
    }
    
    static let MISSING_GENRE_DATA = "No genre data"
    static let MISSING_DEVELOPER_DATA = "No developer data"
    
    private var loadingAnimationView: NVActivityIndicatorView!
    
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var bigScreenshot: UIImageView!
    
    var detailsLoaded: DetailsLoaded!
    
    var game: Game?
    
    override func viewDidLoad() {
        detailsLoaded = DetailsLoaded({ [unowned self] in
            self.finishLoading()
        })
        setupAnimation()
        addCustomBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startLoading()
        addGameDataAlreadyDownloaded()
        downloadGameData()
    }
    
    private func setupAnimation() {
        let width: CGFloat = 80.0
        let height: CGFloat = width
        
        let x = view.bounds.size.width / 2.0 - width / 2.0
        let y = view.bounds.size.height / 2.0 - height / 2.0 - 50.0
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingAnimationView = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.MyCustomColors.orange, padding: 0.0)
        view.addSubview(loadingAnimationView)
        loadingAnimationView.stopAnimating()
    }
    
    private func startLoading() {
        dataView.isHidden = true
        loadingAnimationView.startAnimating()
    }
    
    private func finishLoading() {
        loadingAnimationView.stopAnimating()
        dataView.isHidden = false
        makeNavbarTransparent()
    }
    
    private func addGameDataAlreadyDownloaded() {
        if let game = game {
            titleLbl.text = game.name
            genreLabel.text = game.genre?.description ?? GameDetailsVC.MISSING_GENRE_DATA
            developerLabel.text = game.developer?.description ?? GameDetailsVC.MISSING_DEVELOPER_DATA
        }
    }
    
    private func downloadGameData() {
        coverImg.kf.setImage(with: game?.coverSmallURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { _ in
                self.detailsLoaded.loaded[DetailsLoaded.COVER] = true
        })
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
