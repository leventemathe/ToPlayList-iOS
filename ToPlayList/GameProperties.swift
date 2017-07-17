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

class Platform: IdentifiableObject { }


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




