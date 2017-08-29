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
import Firebase

// this is needed because the badge appears/disappears, and it could flicker if the game was moved from one list to another
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

class GameDetailsVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, ErrorHandlerDelegate, CollectionViewSizeDidSetDelegate, GADBannerViewDelegate {
    
    typealias OnFinishedListener = () -> ()
    
    struct DetailsLoaded {
        
        static let LIST_STATE = "listState"
        static let GENRE = "genre"
        static let DEVELOPER = "developer"
        static let PUBLISHER = "publisher"
        static let DESCRIPTION = "description"
        static let STATUS = "status"
        static let CATEGORY = "category"
        static let FRANCHISE = "franchise"
        static let COLLECTION = "collection"
        static let GAME_MODES = "game_modes"
        static let PLAYER_PERSPECTIVES = "player_perspectives"
        static let SCREENSHOTS_SMALL = "screenshots_small"
        static let SCREENSHOTS_BIG = "screenshots_big"
        static let RELEASE_DATES = "release_dates"
        static let VIDEOS = "videos"
        
        private var listener: OnFinishedListener
        
        var loaded = [DetailsLoaded.LIST_STATE: false,
                      DetailsLoaded.GENRE: false,
                      DetailsLoaded.DEVELOPER: false,
                      DetailsLoaded.PUBLISHER: false,
                      DetailsLoaded.DESCRIPTION: false,
                      DetailsLoaded.STATUS: false,
                      DetailsLoaded.CATEGORY: false,
                      DetailsLoaded.FRANCHISE: false,
                      DetailsLoaded.COLLECTION: false,
                      DetailsLoaded.GAME_MODES: false,
                      DetailsLoaded.PLAYER_PERSPECTIVES: false,
                      DetailsLoaded.SCREENSHOTS_SMALL: false,
                      DetailsLoaded.SCREENSHOTS_BIG: false,
                      DetailsLoaded.RELEASE_DATES: false,
                      DetailsLoaded.VIDEOS: true] { // not downloading video links for now, for legal reasons
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
    
    @IBOutlet weak var badgeVCContainer: UIView!
    @IBOutlet weak var badgeVCHeightConstraint: NSLayoutConstraint!
    var badgeVC: BadgeVC?
    
    @IBOutlet weak var franchiseCollectionContainer: ContainerView!
    @IBOutlet weak var franchiseCollectionLabel: UILabel!
    
    @IBOutlet weak var imageCarouselContainer: UIView!
    var imageCarouselVC: ImageCarouselVC?
    
    @IBOutlet weak var releaseDatesContainer: ContainerView!
    @IBOutlet weak var releaseDateVCHeightConstraint: NSLayoutConstraint!
    var releaseDateVC: ReleaseDateVC?
    
    @IBOutlet weak var bannerAd: GADBannerView!
    @IBOutlet weak var bannerContainer: GADBannerView!
    
    var game: Game!
    private var api: GameAPI!
    
    override func viewDidLoad() {
        setupGameAPI()
        setupLoadingListener()
        
        setupAnimation()
        
        addCustomBackButton()
        setupScrollView()
        setupStarImageTapRecognizer()
        setupSwiping()
        setupBadgeVC()
        setupImageCarouselVC()
        setupReleaseDateVC()
        setupBannerAd()
        
        startLoading()
        
        addGameDataAlreadyDownloaded()
        downloadGameData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navVC = navigationController as? NavigationControllerWithCustomBackGestureDelegate {
            if finishedLoading {
                navVC.makeNavbarTransparent()
            }
        }
        setShouldSwipe()
        updateStarState {
            self.detailsLoaded.loaded[DetailsLoaded.LIST_STATE] = true
            self.attachListListeners()
        }
    }
    
    private func setupSwiping() {
        swipeableDetailsCover.game = game
        swipeableDetailsCover.errorHandlerDelegate = self
    }
    
    private func setShouldSwipe() {
        swipeableDetailsCover.shouldPan = ListsUser.loggedIn && ListsUser.verified
    }
    
    private func setupBadgeVC() {
        for vc in childViewControllers {
            if let bVC = vc as? BadgeVC {
                self.badgeVC = bVC
            }
        }
        badgeVC?.constraintsSetDelegate = self
    }
    
    private func setupImageCarouselVC() {
        for vc in childViewControllers {
            if let iVC = vc as? ImageCarouselVC {
                self.imageCarouselVC = iVC
            }
        }
    }
    
    class TableViewDidSetHeightDelegate: DidSetHeightDelegate {
        
        weak var releaseDatesVCHeightConstraint: NSLayoutConstraint!
        
        init(releaseDatesVCHeightConstraint: NSLayoutConstraint) {
            self.releaseDatesVCHeightConstraint = releaseDatesVCHeightConstraint
        }
        
        func didSet(height: CGFloat) {
            releaseDatesVCHeightConstraint.constant = height
        }
    }
    
    private var releaseDateVCDidSetHeightDelegate: TableViewDidSetHeightDelegate?
    
    private func setupReleaseDateVC() {
        for vc in childViewControllers {
            if let rdVC = vc as? ReleaseDateVC {
                self.releaseDateVC = rdVC
                releaseDateVCDidSetHeightDelegate = TableViewDidSetHeightDelegate(releaseDatesVCHeightConstraint: releaseDateVCHeightConstraint)
                self.releaseDateVC!.didSetHeightDelegate = releaseDateVCDidSetHeightDelegate
            }
        }
    }
    
    private func setupBannerAd() {
        bannerAd.adUnitID = Configuration.instance.admob.detailsAdUnitID
        
        bannerAd.rootViewController = self
        bannerContainer.isHidden = true
        bannerAd.delegate = self
        
        let request = GADRequest()
        bannerAd.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerContainer.isHidden = false
    }
    
    func didSetSize(numberOfItems: Int, numberOfRows: Int, sizeOfItems: CGSize, sizeOfMargins: CGSize) {
        let height = sizeOfItems.height * CGFloat(numberOfRows) +
                     sizeOfMargins.height * CGFloat(numberOfRows-1)
        badgeVCHeightConstraint.constant = height
    }
    
    // STAR AND LISTENERS
    
    private func setupStarImageTapRecognizer() {
        starImage.isUserInteractionEnabled = true
        let starTap = UITapGestureRecognizer(target: self, action: #selector(starTapped))
        starImage.addGestureRecognizer(starTap)
    }
    
    func starTapped() {
        ListsList.instance.removeGameFromToPlayAndPlayedList({ result in
            switch result {
            case .success(_):
                self.gameInExclusiveLists.inToPlayList = false
                self.gameInExclusiveLists.inPlayedList = false
            case .failure(_):
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            }
        }, thisGame: game)
    }
    
    private func attachListListeners() {
        if !(ListsUser.loggedIn && ListsUser.verified) {
            return
        }
        //print("\(self): attached listener")
        
        self.listsListenerSystem.attachListeners(withOnAddedToToPlayList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inToPlayList = true
                //print("set content in details view")
            }
        }, withOnRemovedFromToPlayList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inToPlayList = false
                //print("set content in details view")
            }
        }, withOnAddedToPlayedList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inPlayedList = true
                //print("set content in details view")
            }
        }, withOnRemovedFromPlayedList: { game in
            if game == self.game {
                self.gameInExclusiveLists.inPlayedList = false
                //print("set content in details view")
            }
        })
    }
    
    private func updateStarState(_ onComplete: @escaping ()->()) {
        if !(ListsUser.loggedIn && ListsUser.verified) {
            self.gameInExclusiveLists.inToPlayList = false
            self.gameInExclusiveLists.inPlayedList = false
            onComplete()
            return
        }
        ListsList.instance.getToPlayAndPlayedList { result in
            switch result {
            case .failure:
                Alerts.alertWithOKButton(withMessage: Alerts.UNKNOWN_LISTS_ERROR, forVC: self)
            case .success(let lists):
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
            swipeableDetailsCover.setupPlayedBackground()
        } else if gameInExclusiveLists.inToPlayList {
            showStar()
            starImage.image = #imageLiteral(resourceName: "star_to_play_list")
            swipeableDetailsCover.setupToPlayBackground()
        } else {
            hideStar()
            swipeableDetailsCover.resetBackgrounds()
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
        //print("\(self): detached listener")
        listsListenerSystem.detachListeners()
    }
    
    private var finishedLoading = false
    
    private func setupLoadingListener() {
        detailsLoaded = DetailsLoaded({ [unowned self] in
            if self.finishedLoading {
                return
            }
            self.setImages()
            self.setScreenshotCarousel()
            self.finishLoading()
            self.finishedLoading = true
        })
    }
    
    // DOWNLOADING GAME DATA
    
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
        if let navVC = navigationController as? NavigationControllerWithCustomBackGestureDelegate {
            navVC.makeNavbarTransparent()
        }
        showDetails()
    }
    
    private func showDetails() {
        dataView.alpha = 0.0
        dataView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.dataView.alpha = 1.0
        })
    }
    
    private func addGameDataAlreadyDownloaded() {
        if let game = game {
            titleLbl.text = game.name
            genreLabel.text = game.genre?.description ?? GameDetailsVC.MISSING_GENRE_DATA
            developerLabel.text = game.developer?.description ?? GameDetailsVC.MISSING_DEVELOPER_DATA
        }
    }
    
    private func downloadGameData() {
        api.refreshCachedGameIDs(forGame: game, withOnSuccess: { _ in
            self.downloadAll()
        }, withOnFailure: { error in
            self.handleLoadingError(Alerts.SERVER_ERROR)
        })
    }
    
    private func downloadAll() {
        downloadBasics()
        downloadScreenshotURLs()
        // for legal reasons
        //downloadVideoURLs()
        downloadDescription()
        downloadStatus()
        downloadCategory()
        downloadFranchise()
        downloadCollection()
        downloadGameModes()
        downloadPlayerPerspectives()
        downloadReleaseDates()
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
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
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
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
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
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.developerLabel.text = GameDetailsVC.MISSING_PUBLISHER_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.PUBLISHER] = true
                }
            }
        })
    }

    private func downloadScreenshotURLs() {
        downloadBigScreenshotURLs()
        downloadSmallScreenshotURLs()
    }
    
    private func downloadBigScreenshotURLs() {
        api.getScreenshotsBig(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let screenshots):
                self.game.screenshotBigURLs = screenshots
                self.detailsLoaded.loaded[DetailsLoaded.SCREENSHOTS_BIG] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.detailsLoaded.loaded[DetailsLoaded.SCREENSHOTS_BIG] = true
                }
            }
        })
    }
    
    private func downloadSmallScreenshotURLs() {
        api.getScreenshotsSmall(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let screenshots):
                self.game.screenshotSmallURLs = screenshots
                self.detailsLoaded.loaded[DetailsLoaded.SCREENSHOTS_SMALL] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.detailsLoaded.loaded[DetailsLoaded.SCREENSHOTS_SMALL] = true
                }
            }
        })
    }
    
    private func setImages() {
        setCover()
        setBigScreenshot()
    }
    
    private func setCover() {
        self.coverImg.kf.setImage(with: self.game.coverSmallURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
            if image == nil {
                self.coverImg.kf.setImage(with: self.game.coverBigURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                    if image == nil {
                        self.coverImg.kf.setImage(with: self.game.thumbnailURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                            if image == nil {
                                self.coverImg.kf.setImage(with: self.game.screenshotSmallURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                                    if image == nil {
                                        self.coverImg.kf.setImage(with: self.game.screenshotBigURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"))
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    private func setBigScreenshot() {
        self.bigScreenshot.kf.setImage(with: self.game.screenshotBigURL2, placeholder: #imageLiteral(resourceName: "img_missing_screenshot_big") , options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
            if image == nil {
                self.bigScreenshot.kf.setImage(with: self.game.screenshotBigURL, placeholder: #imageLiteral(resourceName: "img_missing_screenshot_big"), options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                    if image == nil {
                        self.bigScreenshot.kf.setImage(with: self.game.screenshotSmallURL2, placeholder: #imageLiteral(resourceName: "img_missing_screenshot_big"), options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                            if image == nil {
                                self.bigScreenshot.kf.setImage(with: self.game.screenshotSmallURL, placeholder: #imageLiteral(resourceName: "img_missing_screenshot_big"))
                            }
                        })
                    }
                })
            }
        })
    }
    
    private func downloadVideoURLs() {
        api.getVideos(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let videos):
                self.game.videoURLs = videos
                self.detailsLoaded.loaded[DetailsLoaded.VIDEOS] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.detailsLoaded.loaded[DetailsLoaded.VIDEOS] = true
                }
            }
        })
    }
    
    private func setScreenshotCarousel() {
        if game.screenshotSmallURLs != nil {
            imageCarouselVC?.addImages(from: game)
        } else {
            imageCarouselContainer.isHidden = true
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
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.descriptionLabel.text = GameDetailsVC.MISSING_DESCRIPTION_DATA
                    self.detailsLoaded.loaded[DetailsLoaded.DESCRIPTION] = true
                    self.showMoreDescriptionButton.isHidden = true
                }
            }
        })
    }
    
    private func downloadStatus() {
        api.getStatus(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let status):
                self.game.status = status
                self.setStatus()
                self.detailsLoaded.loaded[DetailsLoaded.STATUS] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setStatus()
                    self.detailsLoaded.loaded[DetailsLoaded.STATUS] = true
                }
            }
        })
    }
    
    private func downloadCategory() {
        api.getCategory(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let category):
                self.game.category = category
                self.setCategory()
                self.detailsLoaded.loaded[DetailsLoaded.CATEGORY] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setCategory()
                    self.detailsLoaded.loaded[DetailsLoaded.CATEGORY] = true
                }
            }
        })
    }
    
    private func setStatus() {
        if let string = game.status?.name {
            badgeVC?.add(string: string)
        }
    }
    
    private func setCategory() {
        if let string = game.category?.name {
            badgeVC?.add(string: string)
        }
    }
    
    private func downloadFranchise() {
        api.getFranchise(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let franchise):
                self.game.franchise = franchise
                self.setFranchise()
                self.detailsLoaded.loaded[DetailsLoaded.FRANCHISE] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setFranchise()
                    self.detailsLoaded.loaded[DetailsLoaded.FRANCHISE] = true
                }
            }
        })
    }
    
    private func downloadCollection() {
        api.getCollection(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let collection):
                self.game.collection = collection
                self.setCollection()
                self.detailsLoaded.loaded[DetailsLoaded.COLLECTION] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setCollection()
                    self.detailsLoaded.loaded[DetailsLoaded.COLLECTION] = true
                }
            }
        })
    }
    
    private var franchiseCollectionString: String? {
        didSet {
            franchiseCollectionContainer.isHidden = false
            franchiseCollectionLabel.text = franchiseCollectionString
        }
    }
    
    private func buildFranchiseCollectionString(_ string: String) {
        if franchiseCollectionString == nil {
            franchiseCollectionString = string
        } else if franchiseCollectionString != nil && franchiseCollectionString!.characters.count > 0 {
            franchiseCollectionString!.append(", ")
        } else if franchiseCollectionString != nil {
            franchiseCollectionString = string
        }
    }
    
    private func setFranchise() {
        if let string = game.franchise?.name {
            buildFranchiseCollectionString(string)
        }
    }
    
    private func setCollection() {
        if let string = game.collection?.name {
            buildFranchiseCollectionString(string)
        }
    }
    
    private func downloadGameModes() {
        api.getGameModes(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let modes):
                self.game.gameModes = modes
                self.setGameModes()
                self.detailsLoaded.loaded[DetailsLoaded.GAME_MODES] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setGameModes()
                    self.detailsLoaded.loaded[DetailsLoaded.GAME_MODES] = true
                }
            }
        })
    }
    
    private func downloadPlayerPerspectives() {
        api.getPlayerPerspectives(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let perspectives):
                self.game.playerPerspectives = perspectives
                self.setPlayerPerspectives()
                self.detailsLoaded.loaded[DetailsLoaded.PLAYER_PERSPECTIVES] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setPlayerPerspectives()
                    self.detailsLoaded.loaded[DetailsLoaded.PLAYER_PERSPECTIVES] = true
                }
            }
        })
    }
    
    private func setGameModes() {
        if game.gameModes != nil && game.gameModes!.count > 0 {
            var strings = [String]()
            for gameMode in game.gameModes! {
                strings.append(gameMode.getShorterVersion())
            }
            badgeVC?.add(strings: strings)
        }
    }
    
    private func setPlayerPerspectives() {
        if game.playerPerspectives != nil && game.playerPerspectives!.count > 0 {
            var strings = [String]()
            for perspective in game.playerPerspectives! {
                strings.append(perspective.getShorterVersion())
            }
            badgeVC?.add(strings: strings)
        }
    }
    
    private func downloadReleaseDates() {
        api.getReleaseDates(forGame: game, withOnComplete: { result in
            switch result {
            case .success(let releaseDates):
                self.game.releaseDates = releaseDates
                self.setReleaseDates()
                self.detailsLoaded.loaded[DetailsLoaded.RELEASE_DATES] = true
            case .failure(let error):
                switch error {
                case .noInternet:
                    self.handleLoadingError(Alerts.NETWORK_ERROR)
                case .server, .json, .url:
                    self.handleLoadingError(Alerts.SERVER_ERROR)
                case .unknown:
                    self.handleLoadingError(Alerts.UNKNOWN_ERROR)
                case .noData:
                    self.setReleaseDates()
                    self.detailsLoaded.loaded[DetailsLoaded.RELEASE_DATES] = true
                }
            }
        })
    }
    
    private func setReleaseDates() {
        if let releaseDates = game.releaseDates {
            releaseDateVC?.setReleaseDates(releaseDates)
        } else {
            releaseDatesContainer.isHidden = true
        }
    }
    
    private func handleLoadingError(_ message: String) {
        Alerts.alertWithOKButton(withMessage: message, forVC: self)
        self.loadingAnimationView.stopAnimating()
    }
    
    // BACK BUTTON
    
    private func addCustomBackButton() {
        let newBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_button"), style: .plain, target: self, action: #selector(GameDetailsVC.back(sender:)))

        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    func back(sender: UIBarButtonItem?) {
        if let navVC = navigationController as? NavigationControllerWithCustomBackGestureDelegate {
            navVC.resetNavbar()
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    // SCROLLING
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollContentStackView: UIStackView!
    @IBOutlet weak var scrollContentBottomConstraint: NSLayoutConstraint!
    
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
        } else if scrollPos > 0.0 && delta > 0.0 && movingContentHeightConstraint.constant > movingContentHeightConstraintTarget {
            decreaseContentHeight(delta)
        } else if scrollPos < 0.0 && delta < 0.0 && movingContentHeightConstraint.constant < movingContentHeightConstraintStart {
            increaseContentHeight(delta)
        } else if scrollPos < 0.0 && delta < 0.0 &&  movingContentTopConstraint.constant < movingContentTopConstraintStart {
            moveContentDown(delta)
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
        scrollContentBottomConstraint.constant += delta
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private func moveContentDown(_ delta: CGFloat) {
        let distance = movingContentTopConstraintStart - movingContentTopConstraint.constant
        let delta = max(delta, -distance)
        
        movingContentTopConstraint.constant -= delta
        bigScreenShotHeightConstraint.constant -= delta
        scrollContentBottomConstraint.constant += delta
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private let CONTENT_DISAPPEARS_TRESHOLD: CGFloat = 5.0
    
    private func increaseContentHeight(_ delta: CGFloat) {
        let distance = movingContentHeightConstraintStart - movingContentHeightConstraint.constant
        let delta = max(delta, -distance)
        
        movingContentHeightConstraint.constant -= delta
        scrollContentBottomConstraint.constant += delta
        
        if distance < MOVEMENT_HEIGHT / CONTENT_DISAPPEARS_TRESHOLD && movingContent.alpha == 0.0 {
            showMovingContent()
        }
        
        scrollView.contentOffset.y = scrollViewPreviousContentOffset
    }
    
    private func decreaseContentHeight(_ delta: CGFloat) {
        let distance = movingContentHeightConstraint.constant - movingContentHeightConstraintTarget
        let delta = min(delta, distance)
        
        movingContentHeightConstraint.constant -= delta
        scrollContentBottomConstraint.constant += delta
        
        if distance < MOVEMENT_HEIGHT - MOVEMENT_HEIGHT / CONTENT_DISAPPEARS_TRESHOLD && movingContent.alpha == 1.0 {
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
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
            self.movingContent.alpha = 0.0
        }, completion: { success in
            self.showCenteredTitle()
        })
    }
    
    private func showMovingContent() {
        hideCenteredTitle {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                self.movingContent.alpha = 1.0
            })
        }
    }
    
    private func showCenteredTitle() {
        centeredTitle.alpha = 0.0
        centeredTitle.isHidden = false
        centeredTitle.text = titleLbl.text
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
            self.centeredTitle.alpha = 1.0
        })
    }
    
    private func hideCenteredTitle(_ onComplete: @escaping ()->()) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
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





