//
//  Category.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class Category: IdentifiableObject {

    static let MAIN_GAME = "Main game"
    static let UNKNOWN = "Unknown category"
}

class IGDBCategory: Category {
    
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
