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

struct GameInExclusiveLists {
    
    var inToPlayList = false {
        didSet {
            toPlaySet()
        }
    }
    
    var inPlayedList = false {
        didSet {
            playedSet()
        }
    }
    
    mutating private func toPlaySet() {
        if inToPlayList == true {
            inPlayedList = false
        }
    }
    
    mutating private func playedSet() {
        if inPlayedList == true {
            inToPlayList = false
        }
    }
}

class GameDetailsVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, ErrorHandlerDelegate {
    
    typealias OnFinishedListener = () -> ()
    
    struct DetailsLoaded {
        
        static let LIST_STATE = "listState"
        static let COVER = "cover"
        static let BIG_SCREENSHOT = "bigScreenshot"
        static let GENRE = "genre"
        static let DEVELOPER = "developer"
        static let PUBLISHER = "publisher"
        static let DESCRIPTION = "description"
        
        private var listener: OnFinishedListener
        
        var loaded = [DetailsLoaded.LIST_STATE: false,
                      DetailsLoaded.COVER: false,
                      DetailsLoaded.BIG_SCREENSHOT: false,
                      DetailsLoaded.GENRE: false,
                      DetailsLoaded.DEVELOPER: false,
                      DetailsLoaded.PUBLISHER: false,
                      DetailsLoaded.DESCRIPTION: false] {
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
    static let MISSING_PUBLISHER_DATA = "No publisher data"
    static let MISSING_DESCRIPTION_DATA = "No description available. 😞"
    
    private var loadingAnimationView: NVActivityIndicatorView!
    
    var detailsLoaded: DetailsLoaded!
    
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var starBanner: StarBanner!
    @IBOutlet weak var starBannerLeftConstraint: NSLayoutConstraint!
    
    private var starBannerConstraintStart: CGFloat = -100.0
    private var starBannerConstraintTarget: CGFloat = 0.0
    
    private var listsListenerSystem = ToPlayAndPlayedListListeners()
    private var gameInExclusiveLists = GameInExclusiveLists() {
        didSet {
            setStar()
        }
    }
    
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    
    @IBOutlet weak var swipeableDetailsCover: DetailsCover!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var bigScreenshot: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showMoreDescriptionButton: UIButton!
    
    var game: Game!
    private var api: GameAPI!
    
    override func viewDidLoad() {
        setupScrollView()
        setupGameAPI()
        setupAnimation()
        startLoading()
        setupLoadingListener()
        addCustomBackButton()
        self.setupStarImageTapRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateStarState {
            self.detailsLoaded.loaded[DetailsLoaded.LIST_STATE] = true
            self.attachListListeners()
        }
        setupSwiping()
    }
    
    private func setupSwiping() {
        swipeableDetailsCover.game = game
        swipeableDetailsCover.errorHandlerDelegate = self
    }
    
    private func setupStarImageTapRecognizer() {
        starImage.isUserInteractionEnabled = true
        let starTap = UITapGestureRecognizer(target: self, action: #selector(starTapped))
        starImage.addGestureRecognizer(starTap)
    }
    
    func starTapped() {
        ListsList.instance.removeGameFromToPlayAndPlayedList({ result in
            switch result {
            case .succes(_):
                self.gameInExclusiveLists.inToPlayList = false
                self.gameInExclusiveLists.inPlayedList = false
            case .failure(_):
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            }
        }, thisGame: game)
    }
    
    private func attachListListeners() {
        self.listsListenerSystem.attachListeners(withOnAddedToToPlayList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inToPlayList = true
                print("set content in details view")
            }
        }, withOnRemovedFromToPlayList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inToPlayList = false
                print("set content in details view")
            }
        }, withOnAddedToPlayedList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inPlayedList = true
                print("set content in details view")
            }
        }, withOnRemovedFromPlayedList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inPlayedList = false
                print("set content in details view")
            }
        })
    }
    
    private func updateStarState(_ onComplete: @escaping ()->()) {
        if !ListsUser.loggedIn {
            self.gameInExclusiveLists.inToPlayList = false
            self.gameInExclusiveLists.inPlayedList = false
            onComplete()
            return
        }
        ListsList.instance.getToPlayAndPlayedList { result in
            switch result {
            case .failure:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            case .succes(let lists):
                if lists.toPlay.contains(self.game) {
                    self.gameInExclusiveLists.inToPlayList = true
                } else if lists.played.contains(self.game) {
                    self.gameInExclusiveLists.inPlayedList = true
                } else {
                    self.gameInExclusiveLists.inToPlayList = false
                    self.gameInExclusiveLists.inPlayedList = false
                }
            }
            onComplete()
        }
    }
    
    private func setStar() {
        if gameInExclusiveLists.inPlayedList {
            showStar()
            starImage.image = #imageLiteral(resourceName: "star_played_list")
        } else if gameInExclusiveLists.inToPlayList {
            showStar()
            starImage.image = #imageLiteral(resourceName: "star_to_play_list")
        } else {
            hideStar()
        }
    }
    
    private func showStar() {
        starBanner.isHidden = false
        starImage.isHidden = false
    }
    
    private func hideStar() {
        starBanner.isHidden = true
        starImage.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listsListenerSystem.detachListeners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        downloadDescription()
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
        
        if publisherLabel.text == GameDetailsVC.MISSING_PUBLISHER_DATA {
            downloadPublisher()
        } else {
            self.detailsLoaded.loaded[DetailsLoaded.PUBLISHER] = true
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
                    self.loadingAnimationView.stopAnimating()
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
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
                    self.loadingAnimationView.stopAnimating()
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
                case .noData:
                    self.developerLabel.text = GameDetailsVC.MISSING_DEVELOPER_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.DEVELOPER] = true
                }
            }
        })
    }
    
    private func downloadPublisher() {
        api.getPublishers(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let pubs):
                self.game.publishers = pubs
                self.publisherLabel.text = self.game.publisher!.description
                self.detailsLoaded.loaded[DetailsLoaded.PUBLISHER] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
                case .noData:
                    self.developerLabel.text = GameDetailsVC.MISSING_PUBLISHER_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.PUBLISHER] = true
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
                    self.loadingAnimationView.stopAnimating()
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
                case .noData:
                    self.bigScreenshot.image = #imageLiteral(resourceName: "img_missing_screenshot_big")
                    self.detailsLoaded.loaded[DetailsLoaded.BIG_SCREENSHOT] = true
                }
            }
        })
    }
    
    private func setBigScreenshot(_ screenshots: [URL]?) {
        self.game.screenshotBigURLs = screenshots
        if self.game.screenshotBigURLs != nil {
            self.bigScreenshot.kf.setImage(with: self.game.screenshotBigURL, placeholder: #imageLiteral(resourceName: "img_missing_screenshot_big"), options: nil, progressBlock: nil, completionHandler: { _ in
                self.detailsLoaded.loaded[DetailsLoaded.BIG_SCREENSHOT] = true
            })
        } else {
            self.bigScreenshot.image = #imageLiteral(resourceName: "img_missing_screenshot_big")
            self.detailsLoaded.loaded[DetailsLoaded.BIG_SCREENSHOT] = true
        }
    }
    
    private func downloadDescription() {
        api.getDescription(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let desc):
                self.game.description = desc
                self.descriptionLabel.text = self.game.description
                self.detailsLoaded.loaded[DetailsLoaded.DESCRIPTION] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    Alerts.alertWithOKButton(withMessage: Alerts.NETWORK_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
                case .server, .json, .url:
                    Alerts.alertWithOKButton(withMessage: Alerts.SERVER_ERROR, forVC: self)
                    self.loadingAnimationView.stopAnimating()
                case .noData:
                    self.descriptionLabel.text = GameDetailsVC.MISSING_DESCRIPTION_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.DESCRIPTION] = true
                    self.showMoreDescriptionButton.isHidden = true
                }
            }
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
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func resetNavbar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    
    
    // SCROLLING
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var movingContent: UIView!
    
    @IBOutlet weak var movingContentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var movingContentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bigScreenShotHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var centeredTitle: UILabel!
    
    private let MOVEMENT: CGFloat = 50.0
    private let MOVEMENT_HEIGHT: CGFloat = 114.0
    private var movingContentTopConstraintStart: CGFloat!
    private var movingContentTopConstraintTarget: CGFloat!
    private var movingContentHeightConstraintStart: CGFloat!
    private var movingContentHeightConstraintTarget: CGFloat!
    
    private var scrollViewPreviousContentOffset: CGFloat = 0.0
    
    private func setupScrollView() {
        scrollView.delegate = self
        
        movingContentTopConstraintStart = movingContentTopConstraint.constant
        movingContentTopConstraintTarget = movingContentTopConstraintStart - MOVEMENT
        
        movingContentHeightConstraintStart = movingContentHeightConstraint.constant
        movingContentHeightConstraintTarget = movingContentHeightConstraintStart - MOVEMENT_HEIGHT
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPos = scrollView.contentOffset.y
        let delta = scrollPos - scrollViewPreviousContentOffset
        
        if scrollPos > 0.0 && delta > 0.0 && movingContentTopConstraint.constant > movingContentTopConstraintTarget {
            moveContentUp(delta)
        } else if scrollPos < 0.0 && delta < 0.0 &&  movingContentTopConstraint.constant < movingContentTopConstraintStart {
            moveContentDown(delta)
        } else if scrollPos > 0.0 && delta > 0.0 && movingContentHeightConstraint.constant > movingContentHeightConstraintTarget {
            decreaseContentHeight(delta)
        } else if scrollPos < 0.0 && delta < 0.0 && movingContentHeightConstraint.constant < movingContentHeightConstraintStart {
            increaseContentHeight(delta)
        } else {
            doRegularScrolling()
            cleanupForTooFastMovement(scrollPos, delta)
        }
    }
    
    private func moveContentUp(_ delta: CGFloat) {
        let distance = movingContentTopConstraint.constant - movingContentTopConstraintTarget
        let delta = min(delta, distance)
        
        movingContentTopConstraint.constant -= delta
        bigScreenShotHeightConstraint.constant -= delta
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private func moveContentDown(_ delta: CGFloat) {
        let distance = movingContentTopConstraintStart - movingContentTopConstraint.constant
        let delta = max(delta, -distance)
        
        movingContentTopConstraint.constant -= delta
        bigScreenShotHeightConstraint.constant -= delta
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private func increaseContentHeight(_ delta: CGFloat) {
        let distance = movingContentHeightConstraintStart - movingContentHeightConstraint.constant
        let delta = max(delta, -distance)
        
        movingContentHeightConstraint.constant -= delta
        
        if distance < MOVEMENT_HEIGHT / 3.0 && movingContent.alpha == 0.0 {
            showMovingContent()
        }
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private func decreaseContentHeight(_ delta: CGFloat) {
        let distance = movingContentHeightConstraint.constant - movingContentHeightConstraintTarget
        let delta = min(delta, distance)
        
        movingContentHeightConstraint.constant -= delta
        
        if distance < MOVEMENT_HEIGHT - MOVEMENT_HEIGHT / 3.0 && movingContent.alpha == 1.0 {
            hideMovingContent()
        }
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private func doRegularScrolling() {
        scrollViewPreviousContentOffset = scrollView.contentOffset.y
    }
    
    private func cleanupForTooFastMovement(_ scrollPos: CGFloat, _ delta: CGFloat) {
        if scrollPos > 0.0 && delta > 0.0 && movingContent.alpha == 1.0 {
            hideMovingContent()
        } else if scrollPos < 0.0 && delta < 0.0 && movingContent.alpha == 0.0 {
            showMovingContent()
        }
    }
    
    private func hideMovingContent() {
        UIView.animate(withDuration: 0.2, animations: {
            self.movingContent.alpha = 0.0
        }, completion: { success in
            self.showCenteredTitle()
        })
    }
    
    private func showMovingContent() {
        hideCenteredTitle {
            UIView.animate(withDuration: 0.2, animations: {
                self.movingContent.alpha = 1.0
            })
        }
    }
    
    private func showCenteredTitle() {
        centeredTitle.alpha = 0.0
        centeredTitle.isHidden = false
        centeredTitle.text = titleLbl.text
        UIView.animate(withDuration: 0.2, animations: {
            self.centeredTitle.alpha = 1.0
        })
    }
    
    private func hideCenteredTitle(_ onComplete: @escaping ()->()) {
        UIView.animate(withDuration: 0.2, animations: {
            self.centeredTitle.alpha = 0.0
        }, completion: { success in
            self.centeredTitle.isHidden = true
            onComplete()
        })
    }
    
    func handleError(_ message: String) {
        Alerts.alertWithOKButton(withMessage: message, forVC: self)
    }
}





