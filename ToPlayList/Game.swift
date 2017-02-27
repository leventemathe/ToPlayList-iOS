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
    
    var thumbnailURL: URL?
    var coverSmallURL: URL?
    var coverBigURL: URL?
    
    private var _genres: [Genre]?
    private var _developers: [Company]?
    
    private var _firstReleaseDate: Double?
    private var _firstReleaseDateAsString: String?
    
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
    
    var genre: Genre? {
        if let genre = _genres?[0] {
            return genre
        }
        return nil
    }
    
    var developer: Company? {
        if let developer = _developers?[0] {
            return developer
        }
        return nil
    }
    
    var genres: [Genre] {
        get {
            if _genres == nil {
                _genres = [Genre]()
            }
            return _genres!
        }
        set {
            _genres = newValue
        }
    }
    
    var developers: [Company] {
        get {
            if _developers == nil {
                _developers = [Company]()
            }
            return _developers!
        }
        set {
            _developers = newValue
        }
    }
    
    var firstReleaseDate: Double? {
        get {
            return _firstReleaseDate
        }
        set {
            _firstReleaseDate = newValue
        }
    }
    
    var firstReleaseDateAsString: String? {
        if _firstReleaseDateAsString == nil {
            if _firstReleaseDate == nil {
                return nil
            }
            _firstReleaseDateAsString = Dates.dateFromUnixTime(_firstReleaseDate!)
        }
        return _firstReleaseDateAsString
    }
    
    func addGenre(_ genre: Genre) {
        genres.append(genre)
    }
    
    func addDeveloper(_ developer: Company) {
        developers.append(developer)
    }
}
