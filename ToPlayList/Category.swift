//
//  Category.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class Category: IdentifiableObject {

}

class IGDBCategory: Category {
    
    static func getString(_ id: UInt64) -> String {
        switch id {
        case 0:
            return "Main game"
        case 1:
            return "DLC/Addon"
        case 2:
            return "Expansion"
        case 3:
            return "Bundle"
        case 4:
            return "Standalone expansion"
        default:
            return "Unknown category"
        }
    }
}
