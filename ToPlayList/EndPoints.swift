//
//  EndPoints.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import FirebaseDatabase

struct ListsEndpoints {

    static let BASE = FIRDatabase.database().reference()
    static let USERS = BASE.child("users")
    static let USERNAMES = BASE.child("usernames")
    static let LISTS = BASE.child("lists")
    
    struct Common {
        static let TIMESTAMP = "timestamp"
    }
    
    struct User {
        static let USERS = "users"
        static let PROVIDER = "provider"
        static let USERNAME = "username"
        static let LISTS = "lists"
    }
    
    struct Username {
        static let USERNAMES = "usernames"
        static let USERID = "userid"
    }
    
    struct List {
        static let LISTS = "lists"
        static let TYPE = "type"
        static let USERID = "userid"
        static let GAMES = "games"
        
        static let TO_PLAY_LIST = "toplay"
        static let PLAYED_LIST = "played"
    }
    
    struct Game {
        static let PROVIDER = "provider"
        static let PROVIDER_ID = "providerid"
        static let NAME = "name"
        static let COVER_URL = "coverurl"
    }
}
