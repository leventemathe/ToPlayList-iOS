//
//  EndPoints.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import FirebaseDatabase

struct ListsEndpoints {

    static let BASE = Database.database().reference()
    static let USERS = BASE.child("users")
    static let LISTS = BASE.child("lists")
    
    struct Common {
        static let TIMESTAMP = "timestamp"
    }
    
    struct User {
        static let USERS = "users"
        static let USERNAME = "username"
        static let PROVIDER = "provider"
    }
    
    struct List {
        static let LISTS = "lists"
        static let TO_PLAY_LIST = "toplay"
        static let PLAYED_LIST = "played"
        static let GAMES = "games"
    }
    
    struct Game {
        static let PROVIDER = "provider"
        static let PROVIDER_ID = "provider_id"
        static let NAME = "name"
        static let COVER_SMALL_URL = "cover_small_url"
        static let COVER_BIG_URL = "cover_big_url"
        static let FIRST_RELEASE_DATE = "first_release_date"
    }
}
