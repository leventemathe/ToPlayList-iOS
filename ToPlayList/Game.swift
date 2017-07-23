//
//  GameListItem.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import Foundation

class Game: IdentifiableObject {
    
    var provider = ""
    // this doesn't really belong here, but doing it this way is much easier than changing list
    var timestamp: Double?
    
    var thumbnailURL: URL?
    
    var coverSmallURL: URL?
    var coverBigURL: URL?
    
    var screenshotSmallURLs: [URL]?
    var screenshotBigURLs: [URL]?
    
    var videoURLs: [Video]?
    
    var genres: [Genre]?
    var developers: [Company]?
    var publishers: [Company]?
    
    var description: String?
    
    var status: Status?
    var category: Category?
    
    var franchise: Franchise?
    var collection: Collection?
    
    var playerPerspectives: [PlayerPerspective]?
    var gameModes: [GameMode]?
    
    var firstReleaseDate: Double?
    
    var releaseDates: [ReleaseDate]?
    
    required init(_ id: UInt64, withName name: String) {
        super.init(id, withName: name)
    }
    
    init(_ id: UInt64, withName name: String, withProvider provider: String) {
        super.init(id, withName: name)
        self.provider = provider
    }
    
    var coverSmallURLAsString: String? {
        if coverSmallURL != nil {
            return coverSmallURL!.absoluteString
        }
        return nil
    }
    
    var coverBigURLAsString: String? {
        if coverBigURL != nil {
            return coverBigURL!.absoluteString
        }
        return nil
    }
    
    var screenshotBigURL: URL? {
        if screenshotBigURLs != nil && screenshotBigURLs!.count > 0 {
            return screenshotBigURLs![0]
        }
        return nil
    }
    
    var screenshotSmallURL: URL? {
        if screenshotSmallURLs != nil && screenshotSmallURLs!.count > 0 {
            return screenshotSmallURLs![0]
        }
        return nil
    }
    
    var screenshotBigURL2: URL? {
        if screenshotBigURLs != nil && screenshotBigURLs!.count > 1 {
            return screenshotBigURLs![1]
        }
        return nil
    }
    
    var screenshotSmallURL2: URL? {
        if screenshotSmallURLs != nil && screenshotSmallURLs!.count > 1 {
            return screenshotSmallURLs![1]
        }
        return nil
    }
    
    var screenshotSmallURLAsString: String? {
        if screenshotSmallURL != nil {
            return screenshotSmallURL!.absoluteString
        }
        return nil
    }
    
    var screenshotBigURLAsString: String? {
        if screenshotBigURL != nil {
            return screenshotBigURL!.absoluteString
        }
        return nil
    }
    
    var screenshotSmallURLAsString2: String? {
        if screenshotSmallURL2 != nil {
            return screenshotSmallURL2!.absoluteString
        }
        return nil
    }
    
    var screenshotBigURLAsString2: String? {
        if screenshotBigURL2 != nil {
            return screenshotBigURL2!.absoluteString
        }
        return nil
    }
    
    var genre: Genre? {
        if genres != nil && genres!.count > 0 {
            return genres![0]
        }
        return nil
    }
    
    var developer: Company? {
        if developers != nil && developers!.count > 0 {
            return developers![0]
        }
        return nil
    }
    
    var publisher: Company? {
        if publishers != nil && publishers!.count > 0 {
            return publishers![0]
        }
        return nil
    }
    
    var gameMode: GameMode? {
        if gameModes != nil && gameModes!.count > 0 {
            return gameModes![0]
        }
        return nil
    }
    
    var playerPerspective: PlayerPerspective? {
        if playerPerspectives != nil && playerPerspectives!.count > 0 {
            return playerPerspectives![0]
        }
        return nil
    }
    
    var firstReleaseDateAsString: String? {
        if firstReleaseDate == nil {
            return nil
        }
        return Dates.dateFromUnixTimeShort(firstReleaseDate!)
    }
    
    func addGenre(_ genre: Genre) {
        if genres == nil {
            genres = [Genre]()
        }
        genres!.append(genre)
    }
    
    func addDeveloper(_ developer: Company) {
        if developers == nil {
            developers = [Company]()
        }
        developers!.append(developer)
    }
}
