//
//  Configuration.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 23..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct FirebaseConfig {
    
    let plist: String
}

struct IGDBConfig {

    let api: (key: String, value: String)
}

struct AdMobConfig {
    
    let applicationID: String
    
    let listsAdUnitID: String
    let releasesAdUnitID: String
    let searchAdUnitID: String
    let detailsAdUnitID: String
}

struct Configuration {
    
    static let instance = Configuration()
    
    private init() {
        guard let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String else {
            fatalError("Failed to initialize configuration environment.")
        }
        
        if configuration.range(of: "Prod") != nil {
            firebase = FirebaseConfig(plist: "GoogleService-Info-Prod")
            igdb = IGDBConfig(api: (key: "Get prod key", value: "TODO: Get prod key"))
            admob = AdMobConfig(applicationID: "Get prod admob ready", listsAdUnitID: "Get prod admob ready", releasesAdUnitID: "Get prod admob ready", searchAdUnitID: "Get prod admob ready", detailsAdUnitID: "Get prod admob ready")
        } else {
            firebase = FirebaseConfig(plist: "GoogleService-Info-Dev")
            igdb = IGDBConfig(api: (key: "X-Mashape-Key", value: "LzBgQredIdmshF4aPcNQhIMrkBS8p1E7CHMjsnLySQKks56JFd"))
            admob = AdMobConfig(applicationID: "ca-app-pub-6151617651580775~5306898046", listsAdUnitID: "ca-app-pub-3940256099942544/2934735716", releasesAdUnitID: "ca-app-pub-3940256099942544/2934735716", searchAdUnitID: "ca-app-pub-3940256099942544/2934735716", detailsAdUnitID: "ca-app-pub-3940256099942544/2934735716")
        }
    }
    
    let firebase: FirebaseConfig
    let igdb: IGDBConfig
    let admob: AdMobConfig
}


