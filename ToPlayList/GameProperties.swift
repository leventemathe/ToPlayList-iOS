//
//  GameProperty.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 23..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

class Genre: IdentifiableObject { }

class Company: IdentifiableObject { }

class Franchise: IdentifiableObject { }

class Collection: IdentifiableObject { }

class PlayerPerspective: IdentifiableObject { }

class GameMode: IdentifiableObject { }

class Platform: IdentifiableObject {
    
    func getShorterVersion() -> String {
        if name.range(of: "Windows") != nil {
            return "Windows"
        }
        if name.range(of: "Nintendo Entertainment System (NES)") != nil {
            return "NES"
        }
        if name.range(of: "Super Nintendo Entertainment System (SNES)") != nil {
            return "SNES"
        }
        if name.range(of: "PlayStation Portable") != nil {
            return "PSP"
        }
        if name.range(of: "3DO") != nil {
            return "3DO"
        }
        if name.range(of: "Family Computer Disk System") != nil {
            return "FDS/FCD"
        }
        if name.range(of: "Virtual Console (Nintendo)") != nil {
            return "Nintendo VC"
        }
        if name.range(of: "Sega Mega Drive/Genesis") != nil {
            return "Sega Genesis"
        }
        if name.range(of: "BBC Microcomputer System") != nil {
            return "BBC Micro"
        }
        if name.range(of: "TurboGrafx-16/PC Engine") != nil {
            return "TurboGrafx"
        }
        if name.range(of: "Neo Geo Pocket Color") != nil {
            return "Neo Geo Pocket C"
        }
        if name.range(of: "Neo Geo Pocket Color") != nil {
            return "Neo Geo Pocket C"
        }
        return name
    }
}


protocol EnumarableProperty {
    
    static func getString(_ id: UInt64) -> String
}

class Category: IdentifiableObject {
    
    static let MAIN_GAME = "Main game"
    static let UNKNOWN = "Unknown category"
}

class Status: IdentifiableObject {
    
    static let RELEASED = "Released"
    static let UNKNOWN = "Unknown status"
}

class Region: IdentifiableObject {
    
}



class IGDBCategory: Category, EnumarableProperty {
    
    static func getString(_ id: UInt64) -> String {
        switch id {
        case 0:
            return Category.MAIN_GAME
        case 1:
            return "DLC"
        case 2:
            return "Expansion"
        case 3:
            return "Bundle"
        case 4:
            return "Expandalone"
        default:
            return Category.UNKNOWN
        }
    }
}

class IGDBStatus: Status, EnumarableProperty {
    
    static func getString(_ id: UInt64) -> String {
        switch id {
        case 0:
            return Status.RELEASED
        case 2:
            return "Alpha"
        case 3:
            return "Beta"
        case 4:
            return "Early access"
        case 5:
            return "Offline"
        case 6:
            return "Cancelled"
        default:
            return Status.UNKNOWN
        }
    }
}

class IGDBRegion: Region, EnumarableProperty {
    
    static func getString(_ id: UInt64) -> String {
        switch id {
        case 1:
            return "Europe"
        case 2:
            return "North America"
        case 3:
            return "Australia"
        case 4:
            return "New Zealand"
        case 5:
            return "Japan"
        case 6:
            return "China"
        case 7:
            return "Asia"
        case 8:
            return "Worldwide"
        default:
            return "Unknown region"
        }
    }
    
    static var defaultRegion: Region {
        return Region(8, withName: "Worldwide")
    }
}




