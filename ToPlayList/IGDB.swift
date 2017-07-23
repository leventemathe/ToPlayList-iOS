//
//  IGDB.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 22..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import Alamofire

func createIDList<T: Sequence>(from ids: T) -> String where T.Iterator.Element == UInt64 {
    var idsString = ""
    for id in ids {
        if idsString.characters.count > 0 {
            idsString.append(",")
        }
        idsString.append(String(describing: id))
    }
    return idsString
}

enum IGDBResult<T> {
    case success(T)
    case failure(IGDBError)
}

enum IGDBError: Error {
    case url
    case server
    case noInternet
    case json
    case noData
    case unknown
    
    static func generateError(fromResponse response: DataResponse<Any>) -> IGDBError {
        if let statuscode = response.response?.statusCode {
            if statuscode >= 400 && statuscode < 500 {
                return .url
            } else if statuscode >= 500 && statuscode < 600 {
                return .server
            }
            return .unknown
        }
        return .noInternet
    }
}

typealias Video = (thumb: URL, video: URL)

// used in case i want to add more apis later, this will make it easy to pick one based on
// provider data in game object

protocol GameAPI {

    func getGames(bySearchString search: String, withLimit limit: Int, withOffset offset: Int, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void)
    func getGames(bySearchString search: String, withLimit limit: Int, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void)
    func getGames(bySearchString search: String, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void)

    func getNewestGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int)
    func getNewestGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int)
    
    func getUpcomingGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int)
    func getUpcomingGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int)
    
    func getGenres(_ onComplete: @escaping (IGDBResult<[Genre]>)->Void, withIDs ids: [UInt64])
    func getCompanies(_ onComplete: @escaping (IGDBResult<[Company]>)->Void, withIDs ids: [UInt64])
    func getFranchises(_ onComplete: @escaping (IGDBResult<[Franchise]>)->Void, withIDs ids: [UInt64])
    func getCollections(_ onComplete: @escaping (IGDBResult<[Collection]>)->Void, withIDs ids: [UInt64])
    func getGameModes(_ onComplete: @escaping (IGDBResult<[GameMode]>)->Void, withIDs ids: [UInt64])
    func getPlayerPerspectives(_ onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void, withIDs ids: [UInt64])
    func getPlatforms(_ onComplete: @escaping (IGDBResult<[Platform]>)->Void, withIDs ids: [UInt64])
    
    func getGenres(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Genre]>)->Void)
    func getDevelopers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void)
    func getPublishers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void)
    
    func getScreenshotsSmall(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void)
    func getScreenshotsBig(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void)
    
    func getVideos(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Video]>)->Void)
    
    func getDescription(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<String>)->Void)
    
    func getStatus(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Status>)->Void)
    func getCategory(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Category>)->Void)
    
    func getFranchise(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Franchise>)->Void)
    func getCollection(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Collection>)->Void)
    
    func getGameModes(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[GameMode]>)->Void)
    func getPlayerPerspectives(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void)
    
    func getReleaseDates(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[ReleaseDate]>)->Void)
}

class IGDB: GameAPI {
    
    static let instance = IGDB()
    
    private init() {}
    
    static let BASE_URL = "https://igdbcom-internet-game-database-v1.p.mashape.com"
    static let GAMES = "/games/"
    static let GENRES = "/genres/"
    static let COMPANIES = "/companies/"
    static let FRANCHISES = "/franchises/"
    static let COLLECTIONS = "/collections/"
    static let GAME_MODES = "/game_modes/"
    static let PLAYER_PERSPECTIVES = "/player_perspectives/"
    static let PLATFORMS = "/platforms/"
    
    static let BASE_URL_IMG = "https://images.igdb.com/igdb/image/upload"
    
    static let IMG_EXTENSION = ".jpg"
    
    static var IMG_THUMB: String {
        if UIScreen.main.scale > 1.0 {
            return "/t_thumb_2x"
        }
        return "/t_thumb"
    }
    
    static var IMG_COVER_SMALL: String {
        if UIScreen.main.scale > 1.0 {
            return "/t_cover_small_2x"
        }
        return "/t_cover_small"
    }
    
    static var IMG_COVER_BIG: String {
        if UIScreen.main.scale > 1.0 {
            return "/t_cover_big_2x"
        }
        return "/t_cover_big"
    }
    
    static var IMG_SCREENSHOT_SMALL: String {
        // Small doesn't exist on the api, so I'm using mid instead
        // 2x is missing often too...
        return "/t_screenshot_med"
    }
    
    static var IMG_SCREENSHOT_BIG: String {
        return "/t_screenshot_big"
    }
    
    static let YOUTUBE_THUMB_BASE = "https://img.youtube.com/vi/"   //vbGdIdHOO3I/hqdefault.jpg
    static let YOUTUBE_THUMB_POSTFIX = "/hqdefault.jpg"
    static let YOUTUBE_VIDEO_BASE = "https://www.youtube.com/watch?v="
    
    static let PROVIDER = "IGDB"
    
    private static let HEADERS: HTTPHeaders = [
        IGDBKeys.BASE_KEY.key: IGDBKeys.BASE_KEY.value
    ]
    
    func getGames(bySearchString search: String, withLimit limit: Int, withOffset offset: Int, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void) {
        let url =  IGDB.BASE_URL + IGDB.GAMES
        let parameters: Parameters = ["fields": "id,name,first_release_date,cover",
                                      "limit": limit,
                                      "offset": offset,
                                      "search": search]
        
        Alamofire.request(url, parameters: parameters, headers: IGDB.HEADERS).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? JSON {
                    let result = IGDBJSON.instance.getGamesBySearch(json)
                    switch result {
                    case .success(let games):
                        onComplete(.success(games))
                    case .failure(let error):
                        onComplete(.failure(error))
                    }
                }
            case .failure(_):
                onComplete(IGDBResult.failure(IGDBError.generateError(fromResponse: response)))
            }
        }
    }
    
    func getGames(bySearchString search: String, withLimit limit: Int, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void) {
        getGames(bySearchString: search, withLimit: limit, withOffset: 0, withOnComplete: onComplete)
    }
    
    func getGames(bySearchString search: String, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void) {
        getGames(bySearchString: search, withLimit: 10, withOffset: 0, withOnComplete: onComplete)
    }
    
    private enum Relation {
        case lessThan
        case greaterThan
    }
    
    private enum Order {
        case ascending
        case descending
    }
    
    private func getGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int, wihtRelation relation: Relation, inOrder order: Order, withDate date: Double) {
        let url =  IGDB.BASE_URL + IGDB.GAMES
        
        var relationString: String!
        var orderString: String!
        
        switch relation {
        case .lessThan:
            relationString = "lt"
        case .greaterThan:
            relationString = "gt"
        }
        switch order {
        case .ascending:
            orderString = "asc"
        case .descending:
            orderString = "desc"
        }
        
        let parameters: Parameters = ["fields": "id,name,first_release_date,release_dates,genres,developers,cover",
                                      "order": "first_release_date:\(orderString!)",
                                      "filter[first_release_date][\(relationString!)]": Int64(date) * 1000,
                                      "limit": limit,
                                      "offset": offset]
        
        Alamofire.request(url, parameters: parameters, headers: IGDB.HEADERS).validate().responseJSON { response in
            //print(response.debugDescription)
            switch response.result {
            case .success(let value):
                if let json = value as? JSON {
                    let result = IGDBJSON.instance.getNewestGameList(json)
                    switch result {
                    case .success(let gameData):
                        self.loadFromGameIDs(onComplete, fromGameData: gameData)
                    case .failure(let error):
                        onComplete(IGDBResult.failure(error))
                    }
                }
            case .failure(_):
                onComplete(IGDBResult.failure(IGDBError.generateError(fromResponse: response)))
            }
        }
    }
    
    private func getGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, wihtRelation relation: Relation, inOrder order: Order, withDate date: Double) {
        getGamesList(onComplete, withLimit: limit, withOffset: 0, wihtRelation: relation, inOrder: order, withDate: date)
    }
    
    func getNewestGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int) {
        getGamesList(onComplete, withLimit: limit, withOffset: offset, wihtRelation: .lessThan, inOrder: .descending, withDate: Dates.dateForNewestReleases())
    }
    
    func getNewestGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int) {
        getNewestGames(onComplete, withLimit: limit, withOffset: 0)
    }
    
    func getUpcomingGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int) {
        getGamesList(onComplete, withLimit: limit, withOffset: offset, wihtRelation: .greaterThan, inOrder: .ascending, withDate: Dates.dateForUpcomingReleases())
    }
    
    func getUpcomingGames(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int) {
        getNewestGames(onComplete, withLimit: limit, withOffset: 0)
    }
    
    private func loadFromGameIDs(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, fromGameData gameData: GameData) {
        var genreLoaded = false
        var devLoaded = false
        
        self.getGenres({ result in
            switch result {
            case .success(let genres):
                self.handleGenreResult(genres, forGameData: gameData)
                genreLoaded = true
                if genreLoaded && devLoaded {
                    onComplete(IGDBResult.success(self.getGames(fromGameData: gameData)))
                }
            case .failure(let error):
                onComplete(IGDBResult.failure(error))
            }
        }, withIDs: self.buildGenreIDs(gameData))
        
        self.getCompanies({ result in
            switch result {
            case .success(let devs):
                self.handleDevelopersResult(devs, forGameData: gameData)
                devLoaded = true
                if genreLoaded && devLoaded {
                    onComplete(IGDBResult.success(self.getGames(fromGameData: gameData)))
                }
            case .failure(let error):
                onComplete(IGDBResult.failure(error))
            }
        }, withIDs: self.buildDeveloperIDs(gameData))
    }
    
    private func buildGenreIDs(_ gameData: GameData) -> [UInt64] {
        var set = Set<UInt64>()
        for (_, ids) in gameData {
            if let genres = ids.genres {
                for genre in genres {
                    set.insert(genre)
                }
            }
        }
        return set.sorted()
    }
    
    private func buildDeveloperIDs(_ gameData: GameData) -> [UInt64] {
        var set = Set<UInt64>()
        for (_, ids) in gameData {
            if let devs = ids.developers {
                for dev in devs {
                    set.insert(dev)
                }
            }
        }
        return set.sorted()
    }
    
    private func getGames(fromGameData gameData: GameData) -> [Game] {
        var result = [Game]()
        for (game, _) in gameData {
            result.append(game)
        }
        return result
    }
    
    private func handleGenreResult(_ genres: [Genre], forGameData gameData: GameData) {
        for genre in genres {
            for (game, gameIDs) in gameData {
                if gameIDs.genres == nil {
                    continue
                }
                for genreID in gameIDs.genres! {
                    if genreID == genre.id {
                        game.addGenre(genre)
                    }
                }
            }
        }
    }
    
    private func handleDevelopersResult(_ devs: [Company], forGameData gameData: GameData) {
        for dev in devs {
            for (game, gameIDs) in gameData {
                if gameIDs.developers == nil {
                    continue
                }
                for devID in gameIDs.developers! {
                    if devID == dev.id {
                        game.addDeveloper(dev)
                    }
                }
            }
        }
    }
    
    private func get<T: IdentifiableObject>(_ onComplete: @escaping (IGDBResult<[T]>)->Void, withURL url: String, withParams parameters: Parameters, withHeaders headers: HTTPHeaders) {
        Alamofire.request(url, parameters: parameters, headers: headers).responseJSON { response in
            //print(response.debugDescription)
            switch response.result {
            case .success(let value):
                if let json = value as? [Any] {
                    let result: IGDBResult<[T]> = IGDBJSON.instance.get(json)
                    switch result {
                    case .success(let ts):
                        onComplete(IGDBResult.success(ts))
                    case .failure(let error) :
                        print("getting T failed while jsoning inside")
                        onComplete(IGDBResult.failure(error))
                    }
                } else {
                    print("getting T failed while jsoning outside")
                    onComplete(IGDBResult.failure(.json))
                }
            case .failure(_):
                //print(response.debugDescription)
                onComplete(IGDBResult.failure(IGDBError.generateError(fromResponse: response)))
            }
        }
    }
    
    func getGenres(_ onComplete: @escaping (IGDBResult<[Genre]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([Genre]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.GENRES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    func getCompanies(_ onComplete: @escaping (IGDBResult<[Company]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([Company]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.COMPANIES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    func getFranchises(_ onComplete: @escaping (IGDBResult<[Franchise]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([Franchise]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.FRANCHISES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    
    func getCollections(_ onComplete: @escaping (IGDBResult<[Collection]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([Collection]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.COLLECTIONS)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    func getGameModes(_ onComplete: @escaping (IGDBResult<[GameMode]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([GameMode]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.GAME_MODES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    func getPlayerPerspectives(_ onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([PlayerPerspective]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.PLAYER_PERSPECTIVES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    func getPlatforms(_ onComplete: @escaping (IGDBResult<[Platform]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.success([Platform]()))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.PLATFORMS)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    private var cachedGameIDs: GameIDs?
    
    private func refreshCachedGameIDs(forGame game: Game, withOnSuccess onSuccess: @escaping (GameIDs)->(), withOnFailure onFailure: @escaping (IGDBError)->()) {
        if cachedGameIDs != nil && game.id == cachedGameIDs!.id {
            onSuccess(cachedGameIDs!)
            return
        } else {
            let url =  IGDB.BASE_URL + IGDB.GAMES + "\(game.id)"
            let parameters: Parameters = ["fields": "first_release_date,release_dates,genres,developers,publishers,screenshots,videos,summary,status,category,franchise,collection,game_modes,player_perspectives"]
            
            Alamofire.request(url, parameters: parameters, headers: IGDB.HEADERS).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [Any] {
                        let result = IGDBJSON.instance.getGameIDs(json, forGame: game)
                        switch result {
                        case .success(let gameIDs):
                            self.cachedGameIDs = gameIDs
                            onSuccess(self.cachedGameIDs!)
                        case .failure(let error) :
                            onFailure(error)
                        }
                    } else {
                        onFailure(.json)
                        print("failed getting cahced game ids inside")
                    }
                case .failure(_):
                    onFailure(IGDBError.generateError(fromResponse: response))
                    print("failed getting cahced game ids")
                }
            }

        }
    }
    
    func getGenres(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Genre]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let genres = gameIDs.genres {
                self.getGenres(onComplete, withIDs: genres)
            } else {
                print("no data error")
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            print("failed getting cached game ids in getGenres")
            onComplete(.failure(error))
        })
    }
    
    func getDevelopers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let devs = gameIDs.developers {
                self.getCompanies(onComplete, withIDs: devs)
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            print("failed getting cahced game ids in getdevs")
            onComplete(.failure(error))
        })
    }
    
    func getPublishers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let pubs = gameIDs.publishers {
                self.getCompanies(onComplete, withIDs: pubs)
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    private enum ScreenshotSize {
        case SMALL
        case BIG
    }
    
    func getScreenshotsSmall(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { _ in
            if self.cachedGameIDs!.screenshots != nil {
                let urls = self.buildScreenshotURLs(.SMALL)
                onComplete(.success(urls))
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getScreenshotsBig(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { _ in
            if self.cachedGameIDs!.screenshots != nil {
                let urls = self.buildScreenshotURLs(.BIG)
                onComplete(.success(urls))
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    private func buildScreenshotURLs(_ size: ScreenshotSize) -> [URL] {
        var urls = [URL]()
        // changing this to optional, to set it later, makes the URL initializer return nil
        var sizeString = IGDB.IMG_SCREENSHOT_BIG
        
        switch size {
        case .SMALL:
            sizeString = IGDB.IMG_SCREENSHOT_SMALL
        case .BIG:
            sizeString = IGDB.IMG_SCREENSHOT_BIG
        }
        
        for id in cachedGameIDs!.screenshots! {
            if let url = URL(string: "\(IGDB.BASE_URL_IMG)\(sizeString)/\(id)\(IGDB.IMG_EXTENSION)") {
                urls.append(url)
            }
        }
        return urls
    }
    
    func getVideos(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Video]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { _ in
            if self.cachedGameIDs!.videos != nil {
                let urls = self.buildVideoURLs()
                onComplete(.success(urls))
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    private func buildVideoURLs() -> [Video] {
        var result = [Video]()
        for id in cachedGameIDs!.videos!  {
            if let thumbURL = URL(string: "\(IGDB.YOUTUBE_THUMB_BASE)\(id)\(IGDB.YOUTUBE_THUMB_POSTFIX)"),
                let videoURL = URL(string: "\(IGDB.YOUTUBE_VIDEO_BASE)\(id)") {
                
                result.append((thumb: thumbURL, video: videoURL))
            }
        }
        return result
    }
    
    func getDescription(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<String>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let desc = gameIDs.description {
                onComplete(.success(desc))
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getStatus(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Status>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let statusID = gameIDs.status {
                let status = Status(statusID, withName: IGDBStatus.getString(statusID))
                onComplete(.success(status))
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getCategory(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Category>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let catID = gameIDs.category {
                let cat = Category(catID, withName: IGDBCategory.getString(catID))
                onComplete(.success(cat))
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getFranchise(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Franchise>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let franchise = gameIDs.franchise {
                self.getFranchises({ result in
                    switch result {
                    case .failure(let error):
                        onComplete(.failure(error))
                    case .success(let result):
                        if result.count > 0 {
                            onComplete(.success(result[0]))
                        } else {
                            onComplete(.failure(.server))
                        }
                    }
                }, withIDs: [franchise])
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getCollection(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Collection>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let collection = gameIDs.collection {
                self.getCollections({ result in
                    switch result {
                    case .failure(let error):
                        onComplete(.failure(error))
                    case .success(let result):
                        if result.count > 0 {
                            onComplete(.success(result[0]))
                        } else {
                            onComplete(.failure(.server))
                        }
                    }
                }, withIDs: [collection])
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getGameModes(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[GameMode]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let modes = gameIDs.gameModes {
                self.getGameModes(onComplete, withIDs: modes)
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getPlayerPerspectives(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let perspectives = gameIDs.playerPerspectives {
                self.getPlayerPerspectives(onComplete, withIDs: perspectives)
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    func getReleaseDates(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[ReleaseDate]>)->Void) {
        refreshCachedGameIDs(forGame: game, withOnSuccess: { gameIDs in
            if let releaseDateIDs = gameIDs.releaseDateIDs {
                let platformIDs = releaseDateIDs.map({ $0.platformID })
                self.getPlatforms({ result in
                    switch result {
                    case .success(let platforms):
                        let releaseDates = self.buildReleaseDates(releaseDateIDs: releaseDateIDs, platforms: platforms)
                        onComplete(.success(releaseDates))
                    case .failure(let error):
                        onComplete(.failure(error))
                    }
                }, withIDs: platformIDs)
            } else {
                onComplete(.failure(.noData))
            }
        }, withOnFailure: { error in
            onComplete(.failure(error))
        })
    }
    
    // this function assumes one-to-one pairing of dates to platforms, as expected from the igdb api
    private func buildReleaseDates(releaseDateIDs: [ReleaseDateID], platforms: [Platform]) -> [ReleaseDate] {
        var result = [ReleaseDate]()
        for id in releaseDateIDs {
            let platform = platforms.filter({ $0.id == id.platformID })[0]
            var region = IGDBRegion.defaultRegion
            if let regionID = id.regionID {
                region = Region(regionID, withName: IGDBRegion.getString(regionID))
            }
            let releaseDate = ReleaseDate(platform: platform, date: id.date, region: region)
            result.append(releaseDate)
        }
        return result
    }
}


