//
//  ToPlayList.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 24..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FirebaseAuth

struct List {
    
    static let instance = List()
    
    private init() {}
    
    func createToPlayList(_ onComplete: @escaping (String)->()) {
        createList(onComplete, withType: "to_play_list")
    }
    
    func createPlayedList(_ onComplete: @escaping (String)->()) {
        createList(onComplete, withType: "played_list")
    }
    
    private func createList(_ onComplete: @escaping (String)->(), withType type: String) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //TODO handle error
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let value: [String: Any] = ["timestamp": timestamp, "type": type, "userid": uid]
        LISTS_DB_LISTS.childByAutoId().updateChildValues(value) { (error, ref) in
            onComplete(ref.key)
        }
    }
}
