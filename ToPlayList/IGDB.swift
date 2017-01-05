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
    
    private static let HEADERS: HTTPHeaders = [
        IGDBKeys.BASE_KEY.key: IGDBKeys.BASE_KEY.value
    ]
    
    public func getNewestGamesList(_ onComplete: @escaping (IGDBResult<[Game]>)->Void) {
        let url =  IGDB.BASE_URL + IGDB.GAMES
        let currentDate = Int64(Date().timeIntervalSince1970) * 1000
        let parameters: Parameters = ["fields": "id,name,first_release_date,release_dates,genres,developers,cover",
                                      "order": "first_release_date:desc",
                                      "filter[first_release_date][lt]": currentDate,
                                      "limit": 10]
        
        Alamofire.request(url, parameters: parameters, headers: IGDB.HEADERS).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? JSON {
                    let result = IGDBJSON.instance.getNewestGameList(json)
                    switch result {
                    case .succes(let gameData):
                        self.loadFromGameIDs(onComplete, from: gameData)
                    case .failure(let error):
                        onComplete(IGDBResult.failure(error))
                    }
                }
            case .failure(_):
                onComplete(IGDBResult.failure(IGDBError.generateError(from: response)))
            }
        }
    }
    
    private func loadFromGameIDs(_ onComplete: @escaping (IGDBResult<[Game]>)->Void, from gameData: GameData) {
        var genreLoaded = false
        var devLoaded = false
        
        self.getGenres({ result in
            switch result {
            case .succes(let genres):
                self.handleGenreResult(genres, for: gameData)
                genreLoaded = true
                if genreLoaded && devLoaded {
                    onComplete(IGDBResult.succes(Array(gameData.keys)))
                }
            case .failure(let error):
                onComplete(IGDBResult.failure(error))
            }
        }, withIDs: self.buildGenreIDs(Array(gameData.values)))
        
        self.getCompanies({ result in
            switch result {
            case .succes(let devs):
                self.handleDevelopersResult(devs, for: gameData)
                devLoaded = true
                if genreLoaded && devLoaded {
                    onComplete(IGDBResult.succes(Array(gameData.keys)))
                }
            case .failure(let error):
                onComplete(IGDBResult.failure(error))
            }
        }, withIDs: self.buildDeveloperIDs(Array(gameData.values)))
    }
    
    private func buildGenreIDs(_ ids: [GameIDs]) -> Set<Int> {
        var result = Set<Int>()
        for gameIDs in ids {
            if let genres = gameIDs.genres {
                for genre in genres {
                    result.insert(genre)
                }
            }
        }
        return result
    }
    
    private func buildDeveloperIDs(_ ids: [GameIDs]) -> Set<Int> {
        var result = Set<Int>()
        for gameIDs in ids {
            if let devs = gameIDs.developers {
                for dev in devs {
                    result.insert(dev)
                }
            }
        }
        return result
    }
    
    private func handleGenreResult(_ genres: [Genre], for gameData: GameData) {
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
    
    private func handleDevelopersResult(_ devs: [Company], for gameData: GameData) {
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
        Alamofire.request(url, parameters: parameters, headers: headers).validate().responseJSON { response in
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


