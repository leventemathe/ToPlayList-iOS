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
typealias GameData = [Game: GameIDs]

struct IGDBJSON {

    static let instance = IGDBJSON()
    
    private init() {}
    
    func getNewestGameList(_ json: JSON) -> IGDBResult<GameData> {
        var result = GameData()
        for any in json {
            if let obj = any as? JSONPair, let game = setGame(from: obj) {
                result[game] = setGameIDs(from: obj, with: game.id)
            } else {
                return IGDBResult.failure(IGDBError.jsonError)
            }
        }
        return IGDBResult.succes(result)
    }
    
    private func setGame(from obj: JSONPair) -> Game? {
        if let name = obj["name"] as? String, let id = obj["id"] as? Int {
            let game = Game(id, withName: name)
            
            if let coverURL = (obj["cover"] as? JSONPair)?["cloudinary_id"] as? String {
                game.coverURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_THUMB)/\(coverURL)")
            }
            return game
        }
        return nil
    }
    
    private func setGameIDs(from obj: JSONPair, with gameID: Int) -> GameIDs {
        var gameIDs = GameIDs(gameID)
        
        if let genreIDs = obj["genres"] as? [Int] {
            gameIDs.genres = genreIDs
        }
        if let developerIDs = obj["developers"] as? [Int] {
            gameIDs.developers = developerIDs
        }
        if let publisherIDs = obj["publishers"] as? [Int] {
            gameIDs.publishers = publisherIDs
        }
        return gameIDs
    }
    
    func get<T: IdentifiableObject>(_ json: JSON) -> IGDBResult<[T]> {
        var ts = [T]()
        for any in json {
            if let obj = any as? JSONPair, let id = obj["id"] as? Int, let name = obj["name"] as? String {
                ts.append(T(id, withName: name))
            }
        }
        if(ts.count < 1) {
            return IGDBResult.failure(IGDBError.jsonError)
        }
        return IGDBResult.succes(ts)
    }
}
