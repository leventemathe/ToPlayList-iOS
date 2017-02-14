//
//  EndPoints.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import FirebaseDatabase

let LISTS_DB_BASE = FIRDatabase.database().reference()
let LISTS_DB_USERS = LISTS_DB_BASE.child("users")
let LISTS_DB_USERNAMES = LISTS_DB_BASE.child("usernames")
let LISTS_DB_LISTS = LISTS_DB_BASE.child("lists")
let LISTS_DB_GAMES = LISTS_DB_BASE.child("games")
