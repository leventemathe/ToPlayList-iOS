//
//  IGDB.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 22..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import Alamofire

func createIDList<T: Sequence>(from ids: T) -> String where T.Iterator.Element == Int {
    var idsString = ""
    for id in ids {
        if idsString.characters.count > 1 {
            idsString.append(",")
        }
        idsString.append(String(describing: id))
    }
    return idsString
}

enum IGDBResult<T> {
    case succes(T)
    case failure(IGDBError)
}

enum IGDBError: Error {
    case urlError
    case serverError
    case noInternetError
    case jsonError
    
    static func generateError(from response: DataResponse<Any>) -> IGDBError {
        if let statuscode = response.response?.statusCode {
            if statuscode >= 400 && statuscode < 500 {
                return .urlError
            } else if statuscode >= 500 && statuscode < 600 {
                return .serverError
            }
        }
        return .noInternetError
    }
}

struct IGDB {
    
    static let instance = IGDB()
    
    private init() {}
    
    static let BASE_URL = "https://igdbcom-internet-game-database-v1.p.mashape.com"
    static let GAMES = "/games/"
    static let GENRES = "/genres/"
    static let COMPANIES = "/companies/"
    
    static let BASE_URL_IMG = "https://images.igdb.com/igdb/image/upload"
    static var IMG_THUMB: String {
        if UIScreen.main.scale > 1.0 {
            return "/t_thumb_2x"
        }
        return "/t_thumb"
    }
    
    static let PROVIDER = "IGDB"
    
    private static let HEADERS: HTTPHeaders = [
        IGDBKeys.BASE_KEY.key: IGDBKeys.BASE_KEY.value
    ]
    
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
                    case .succes(let gameData):
                        self.loadFromGameIDs(onComplete, fromGameData: gameData)
                    case .failure(let error):
                        onComplete(IGDBResult.failure(error))
                    }
                }
            case .failure(_):
                onComplete(IGDBResult.failure(IGDBError.generateError(from: response)))
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
            case .succes(let genres):
                self.handleGenreResult(genres, forGameData: gameData)
                genreLoaded = true
                if genreLoaded && devLoaded {
                    onComplete(IGDBResult.succes(self.getGames(gameData)))
                }
            case .failure(let error):
                onComplete(IGDBResult.failure(error))
            }
        }, withIDs: self.buildGenreIDs(gameData))
        
        self.getCompanies({ result in
            switch result {
            case .succes(let devs):
                self.handleDevelopersResult(devs, forGameData: gameData)
                devLoaded = true
                if genreLoaded && devLoaded {
                    onComplete(IGDBResult.succes(self.getGames(gameData)))
                }
            case .failure(let error):
                onComplete(IGDBResult.failure(error))
            }
        }, withIDs: self.buildDeveloperIDs(gameData))
    }
    
    private func buildGenreIDs(_ gameData: GameData) -> Set<Int> {
        var result = Set<Int>()
        for (_, ids) in gameData {
            if let genres = ids.genres {
                for genre in genres {
                    result.insert(genre)
                }
            }
        }
        return result
    }
    
    private func buildDeveloperIDs(_ gameData: GameData) -> Set<Int> {
        var result = Set<Int>()
        for (_, ids) in gameData {
            if let devs = ids.developers {
                for dev in devs {
                    result.insert(dev)
                }
            }
        }
        return result
    }
    
    private func getGames(_ gameData: GameData) -> [Game] {
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
            print(response.debugDescription)
            switch response.result {
            case .success(let value):
                if let json = value as? [Any] {
                    let result: IGDBResult<[T]> = IGDBJSON.instance.get(json)
                    switch result {
                    case .succes(let ts):
                        onComplete(IGDBResult.succes(ts))
                    case .failure(let error) :
                        onComplete(IGDBResult.failure(error))
                    }
                }
            case .failure(_):
                onComplete(IGDBResult.failure(IGDBError.generateError(from: response)))
            }
        }
    }
    
    public func getGenres(_ onComplete: @escaping (IGDBResult<[Genre]>)->Void, withIDs ids: Set<Int>) {
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.GENRES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
    
    public func getCompanies(_ onComplete: @escaping (IGDBResult<[Company]>)->Void, withIDs ids: Set<Int>) {
        let idsString = createIDList(from: ids)
        let url = "\(IGDB.BASE_URL)\(IGDB.COMPANIES)\(idsString)/"
        let parameters = ["fields": "id,name"]
        
        get(onComplete, withURL: url, withParams: parameters, withHeaders: IGDB.HEADERS)
    }
}


