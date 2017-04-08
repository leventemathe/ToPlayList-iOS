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
        static let GENRE = "genre"
        static let DEVELOPER = "developer"
        
        private var listener: OnFinishedListener
        
        var loaded = [DetailsLoaded.COVER: false,
                      DetailsLoaded.BIG_SCREENSHOT: false,
                      DetailsLoaded.DEVELOPER: false,
                      DetailsLoaded.GENRE: false] {
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
    
    var game: Game!
    private var api: GameAPI!
    
    override func viewDidLoad() {
        setupGameAPI()
        setupLoadingListener()
        addCustomBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupAnimation()
        startLoading()
        addGameDataAlreadyDownloaded()
        downloadGameData()
    }
    
    private func setupLoadingListener() {
        detailsLoaded = DetailsLoaded({ [unowned self] in
            self.finishLoading()
        })
    }
    
    private func setupGameAPI() {
        switch game.provider {
        case "IGDB":
            api = IGDB.instance
        default:
            api = IGDB.instance
        }
    }
    
    private func setupAnimation() {
        let width: CGFloat = 80.0
        let height: CGFloat = width
        
        let x = view.bounds.size.width / 2.0 - width / 2.0
        let y = view.bounds.size.height / 2.0 - height / 2.0
        
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
        downloadBasics()
        downloadCover()
        downloadBigScreenshots()
    }
    
    private func downloadBasics() {
        if genreLabel.text == GameDetailsVC.MISSING_GENRE_DATA {
            downloadGenre()
        } else {
            self.detailsLoaded.loaded[DetailsLoaded.GENRE] = true
        }
        
        if developerLabel.text == GameDetailsVC.MISSING_DEVELOPER_DATA {
            downloadDeveloper()
        } else {
            self.detailsLoaded.loaded[DetailsLoaded.DEVELOPER] = true
        }
    }
    
    private func downloadGenre() {
        api.getGenres(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let genres):
                self.game.genres = genres
                self.genreLabel.text = self.game.genre!.description
                self.detailsLoaded.loaded[DetailsLoaded.GENRE] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    print("server error on genre")
                case .noData:
                    self.genreLabel.text = GameDetailsVC.MISSING_GENRE_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.GENRE] = true
                }
            }
        })
    }
    
    private func downloadDeveloper() {
        api.getDevelopers(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let devs):
                self.game.developers = devs
                self.developerLabel.text = self.game.developer!.description
                self.detailsLoaded.loaded[DetailsLoaded.DEVELOPER] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    print("server error on dev")
                case .noData:
                    self.developerLabel.text = GameDetailsVC.MISSING_DEVELOPER_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.DEVELOPER] = true
                }
            }
        })
    }
    
    private func downloadCover() {
        coverImg.kf.setImage(with: game.coverSmallURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { _ in
            self.detailsLoaded.loaded[DetailsLoaded.COVER] = true
        })
    }
    
    private func downloadBigScreenshots() {
        api.getScreenshotsBig(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let screenshots):
                self.setBigScreenshot(screenshots)
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                case .noData:
                    self.bigScreenshot.image = #imageLiteral(resourceName: "img_missing")
                    self.detailsLoaded.loaded[DetailsLoaded.BIG_SCREENSHOT] = true
                }
            }
        })
    }
    
    private func setBigScreenshot(_ screenshots: [URL]?) {
        self.game.screenshotBigURLs = screenshots
        if self.game.screenshotBigURLs != nil {
            self.bigScreenshot.kf.setImage(with: self.game.screenshotBigURL, placeholder: #imageLiteral(resourceName: "img_missing"), options: nil, progressBlock: nil, completionHandler: { _ in
                self.detailsLoaded.loaded[DetailsLoaded.BIG_SCREENSHOT] = true
            })
        } else {
            self.bigScreenshot.image = #imageLiteral(resourceName: "img_missing")
            self.detailsLoaded.loaded[DetailsLoaded.BIG_SCREENSHOT] = true
        }
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
