//
//  JSON.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 28..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import Foundation

typealias JSON = [Any]
typealias JSONPair = [String: Any]
typealias GameData = [(Game, GameIDs)]

struct IGDBJSON {

    static let instance = IGDBJSON()
    
    private init() {}
    
    func getNewestGameList(_ json: JSON) -> IGDBResult<GameData> {
        var result = GameData()
        for any in json {
            if let obj = any as? JSONPair, let game = setGame(fromObj: obj) {
                result.append((game, setGameIDs(fromObj: obj, withGameID: game.id)))
            } else {
                return IGDBResult.failure(IGDBError.jsonError)
            }
        }
        return IGDBResult.succes(result)
    }
    
    private func setGame(fromObj obj: JSONPair) -> Game? {
        if let name = obj["name"] as? String, let id = obj["id"] as? UInt64 {
            let game = Game(id, withName: name)
            
            game.provider = IGDB.PROVIDER
            
            if let imgID = (obj["cover"] as? JSONPair)?["cloudinary_id"] as? String {
                game.thumbnailURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_THUMB)/\(imgID)")
                game.coverSmallURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_COVER_SMALL)/\(imgID)")
                game.coverBigURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_COVER_BIG)/\(imgID)")
            }
            if let firsReleaseDate = obj["first_release_date"] as? Double {
                game.firstReleaseDate = firsReleaseDate / 1000.0
            }
            
            return game
        }
        return nil
    }
    
    private func setGameIDs(fromObj obj: JSONPair, withGameID gameID: UInt64) -> GameIDs {
        var gameIDs = GameIDs(gameID)
        
        if let genreIDs = obj["genres"] as? [UInt64] {
            gameIDs.genres = genreIDs
        }
        if let developerIDs = obj["developers"] as? [UInt64] {
            gameIDs.developers = developerIDs
        }
        if let publisherIDs = obj["publishers"] as? [UInt64] {
            gameIDs.publishers = publisherIDs
        }
        return gameIDs
    }
    
    func get<T: IdentifiableObject>(_ json: JSON) -> IGDBResult<[T]> {
        var ts = [T]()
        for any in json {
            if let obj = any as? JSONPair, let id = obj["id"] as? UInt64, let name = obj["name"] as? String {
                ts.append(T(id, withName: name))
            }
        }
        if(ts.count < 1) {
            return IGDBResult.failure(IGDBError.jsonError)
        }
        return IGDBResult.succes(ts)
    }
}
