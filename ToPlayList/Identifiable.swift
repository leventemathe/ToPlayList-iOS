//
//  Identifiable.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 28..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import Foundation

protocol Identifiable: Hashable, Equatable, CustomStringConvertible {
    var id: Int { get }
    var name: String { get }
}

extension Identifiable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    var hashValue: Int {
        return id
    }
    
    var description: String {
        return "\(id) \(name)"
    }
}

class IdentifiableObject: Identifiable {
    
    let _id: Int
    let _name: String
    
    var id: Int { return _id }
    var name: String { return _name }
    
    required init(_ id: Int, withName name: String) {
        _id = id;
        _name = name
    }
}
