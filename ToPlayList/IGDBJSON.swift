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

class IGDBJSON {

    static let instance = IGDBJSON()
    
    private init() {}
    
    func getGamesBySearch(_ json: JSON) -> IGDBResult<[Game]> {
        var games = [Game]()
        for any in json {
            if let obj = any as? JSONPair, let game = setGame(fromObj: obj) {
                games.append(game)
            } else {
                return IGDBResult.failure(IGDBError.json)
            }
        }
        return IGDBResult.success(games)
    }
    
    func getGameList(_ json: JSON) -> IGDBResult<GameData> {
        var result = GameData()
        for any in json {
            if let obj = any as? JSONPair, let game = setGame(fromObj: obj) {
                result.append((game, setGameIDs(fromObj: obj, withGameID: game.id)))
            } else {
                return IGDBResult.failure(IGDBError.json)
            }
        }
        return IGDBResult.success(result)
    }
    
    private func setGame(fromObj obj: JSONPair) -> Game? {
        if let name = obj["name"] as? String, let id = obj["id"] as? UInt64 {
            let game = Game(id, withName: name)
            
            game.provider = IGDB.PROVIDER
            
            if let imgID = (obj["cover"] as? JSONPair)?["cloudinary_id"] as? String {
                game.thumbnailURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_THUMB)/\(imgID)\(IGDB.IMG_EXTENSION)")
                game.coverSmallURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_COVER_SMALL)/\(imgID)\(IGDB.IMG_EXTENSION)")
                game.coverBigURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_COVER_BIG)/\(imgID)\(IGDB.IMG_EXTENSION)")
            }
            if let screenshots = obj["screenshots"] as? [[String: Any]] {
                var screenshotSmallURLs = [URL]()
                var screenshotBigURLs = [URL]()
                for screenshot in screenshots {
                    if let screenshotID = screenshot["cloudinary_id"] as? String {
                        if let smallURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_SCREENSHOT_SMALL)/\(screenshotID)\(IGDB.IMG_EXTENSION)") {
                            screenshotSmallURLs.append(smallURL)
                        }
                        if let bigURL = URL(string: "\(IGDB.BASE_URL_IMG)\(IGDB.IMG_SCREENSHOT_BIG)/\(screenshotID)\(IGDB.IMG_EXTENSION)") {
                            screenshotBigURLs.append(bigURL)
                        }
                    }
                }
                game.screenshotSmallURLs = screenshotSmallURLs
                game.screenshotBigURLs = screenshotBigURLs
            }
            if let firsReleaseDate = obj["first_release_date"] as? Double {
                // date needs to be divided by 1000, because IGDB isn't using standard unix time
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
            return .failure(.noData)
        }
        return IGDBResult.success(ts)
    }
    
    func getGameIDs(_ json: JSON, forGame game: Game) -> IGDBResult<GameIDs> {
        if let obj = json[0] as? JSONPair {
            var gameIDs = setGameIDs(fromObj: obj, withGameID: game.id)
            
            if let screenshots = obj["screenshots"] as? [[String: Any]] {
                var screenshotIDs = [String]()
                for screenshot in screenshots {
                    if let screenshotID = screenshot["cloudinary_id"] as? String {
                        screenshotIDs.append(screenshotID)
                    }
                }
                gameIDs.screenshots = screenshotIDs
            }
            if let videos = obj["videos"] as? [[String: Any]] {
                var videIDs = [String]()
                for video in videos {
                    if let id = video["video_id"] as? String {
                        videIDs.append(id)
                    }
                }
                gameIDs.videos = videIDs
            }
            
            if let desc = obj["summary"] as? String {
                gameIDs.description = desc
            }
            
            if let status = obj["status"] as? UInt64 {
                gameIDs.status = status
            }
            if let category = obj["category"] as? UInt64 {
                gameIDs.category = category
            }
            
            if let franchise = obj["franchise"] as? UInt64 {
                gameIDs.franchise = franchise
            }
            if let collection = obj["collection"] as? UInt64 {
                gameIDs.collection = collection
            }
            
            if let gameModes = obj["game_modes"] as? [UInt64] {
                gameIDs.gameModes = gameModes
            }
            if let playerPerspectives = obj["player_perspectives"] as? [UInt64] {
                gameIDs.playerPerspectives = playerPerspectives
            }
            if let releaseDates = obj["release_dates"] as? [[String: Any]] {
                var releaseDateIDs = [ReleaseDateID]()
                for releaseDate in  releaseDates {
                    if let date = releaseDate["date"] as? Double, let platform = releaseDate["platform"] as? UInt64 {
                        // date needs to be divided by 1000, because IGDB isn't using standard unix time
                        var releaseDateID: ReleaseDateID!
                        if let region = releaseDate["region"] as? UInt64 {
                            releaseDateID = ReleaseDateID(date: date / 1000.0, platformID: platform, regionID: region)
                        } else {
                            releaseDateID = ReleaseDateID(date: date / 1000.0, platformID: platform, regionID: IGDBRegion.defaultRegion.id)
                        }
                        releaseDateIDs.append(releaseDateID)
                    }
                }
                gameIDs.releaseDateIDs = releaseDateIDs
            }
            
            return .success(gameIDs)
        }
        return .failure(.json)
    }
}
