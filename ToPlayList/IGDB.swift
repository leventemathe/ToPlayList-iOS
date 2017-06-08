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

// used in case i want to add more apis later, this will make it easy to pick one based on
// provider data in game object

protocol GameAPI {

    func getGames(bySearchString search: String, withLimit limit: Int, withOffset offset: Int, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void)
    func getGames(bySearchString search: String, withLimit limit: Int, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void)
    func getGames(bySearchString search: String, withOnComplete onComplete: @escaping (IGDBResult<[Game]>)->Void)

    func getGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int, withDate date: Double)
    func getGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withDate date: Double)
    
    func getGenres(_ onComplete: @escaping (IGDBResult<[Genre]>)->Void, withIDs ids: [UInt64])
    func getCompanies(_ onComplete: @escaping (IGDBResult<[Company]>)->Void, withIDs ids: [UInt64])
    func getFranchises(_ onComplete: @escaping (IGDBResult<[Franchise]>)->Void, withIDs ids: [UInt64])
    func getCollections(_ onComplete: @escaping (IGDBResult<[Collection]>)->Void, withIDs ids: [UInt64])
    func getGameModes(_ onComplete: @escaping (IGDBResult<[GameMode]>)->Void, withIDs ids: [UInt64])
    func getPlayerPerspectives(_ onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void, withIDs ids: [UInt64])
    
    func getGenres(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Genre]>)->Void)
    func getDevelopers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void)
    func getPublishers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void)
    
    func getScreenshotsSmall(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void)
    func getScreenshotsBig(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void)
    
    func getDescription(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<String>)->Void)
    
    func getStatus(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Status>)->Void)
    func getCategory(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Category>)->Void)
    
    func getFranchise(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Franchise>)->Void)
    func getCollection(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Collection>)->Void)
    
    func getGameModes(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[GameMode]>)->Void)
    func getPlayerPerspectives(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void)
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
        return "/t_screenshot_med"
    }
    
    static var IMG_SCREENSHOT_BIG: String {
        if UIScreen.main.scale > 1.0 {
            return "/t_screenshot_big_2x"
        }
        return "/t_screenshot_big"
    }
    
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
    
    public func getGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withOffset offset: Int, withDate date: Double = Date().timeIntervalSince1970) {
        let url =  IGDB.BASE_URL + IGDB.GAMES
        let parameters: Parameters = ["fields": "id,name,first_release_date,release_dates,genres,developers,cover",
                                      "order": "first_release_date:desc",
                                      "filter[first_release_date][lt]": Int64(date) * 1000,
                                      "limit": limit,
                                      "offset": offset]
        
        Alamofire.request(url, parameters: parameters, headers: IGDB.HEADERS).validate().responseJSON { response in
            print(response.debugDescription)
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
    
    public func getGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, withLimit limit: Int, withDate date: Double = Date().timeIntervalSince1970) {
        getGamesList(onComplete, withLimit: limit, withOffset: 0, withDate: date)
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
    
    public func getGenres(_ onComplete: @escaping (IGDBResult<[Genre]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.failure(.noData))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.GENRES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    public func getCompanies(_ onComplete: @escaping (IGDBResult<[Company]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.failure(.noData))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.COMPANIES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    public func getFranchises(_ onComplete: @escaping (IGDBResult<[Franchise]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.failure(.noData))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.FRANCHISES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    
    public func getCollections(_ onComplete: @escaping (IGDBResult<[Collection]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.failure(.noData))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.COLLECTIONS)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    public func getGameModes(_ onComplete: @escaping (IGDBResult<[GameMode]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.failure(.noData))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.GAME_MODES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    public func getPlayerPerspectives(_ onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void, withIDs ids: [UInt64]) {
        if ids.count < 1 {
            onComplete(.failure(.noData))
            return
        }
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.PLAYER_PERSPECTIVES)\(idsString)/"
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
            let parameters: Parameters = ["fields": "first_release_date,release_dates,genres,developers,publishers,screenshots,summary,status,category,franchise,collection,game_modes,player_perspectives"]
            
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
    
    public func getGenres(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Genre]>)->Void) {
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
    
    public func getDevelopers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void) {
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
    
    public func getPublishers(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[Company]>)->Void) {
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
    
    public func getScreenshotsSmall(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void) {
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
    
    public func getScreenshotsBig(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[URL]>)->Void) {
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
    
    public func getDescription(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<String>)->Void) {
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
    
    public func getStatus(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Status>)->Void) {
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
    
    public func getCategory(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Category>)->Void) {
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
    
    public func getFranchise(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Franchise>)->Void) {
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
    
    public func getCollection(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<Collection>)->Void) {
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
    
    public func getGameModes(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[GameMode]>)->Void) {
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
    
    public func getPlayerPerspectives(forGame game: Game, withOnComplete onComplete: @escaping (IGDBResult<[PlayerPerspective]>)->Void) {
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
}


