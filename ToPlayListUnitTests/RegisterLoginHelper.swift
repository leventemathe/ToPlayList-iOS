//
//  RegisterLoginHelper.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayListDev
@testable import Firebase

typealias UserData = (email: String, password: String, username: String)
typealias UserDataOptional = (email: String?, password: String?, username: String?)

typealias UserDataLogin = (email: String, password: String)
typealias UserDataLoginOptional = (email: String?, password: String?)

struct RegisterLoginTestHelper {
    
    static  let helperTestCase = XCTestCase()
    
    static func login(_ userData: UserDataLogin, withOnSuccess onSuccess: @escaping ()->(), withOnFailure onFailure: @escaping (LoginServiceError)->()) {
        let loginExp = helperTestCase.expectation(description: "login")
        
        LoginService.instance.login(userData.email, withPassword: userData.password) { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onFailure(error)
            }
            loginExp.fulfill()
        }
        
        helperTestCase.waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    static func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print("Error while logging out: \(error.description))")
        }
    }
    
    static func register(_ userData: UserData, withOnSuccess onSuccess: @escaping (String?)->(), withOnFailure onFailure: @escaping (RegisterServiceError)->()) {
        let registerExp = helperTestCase.expectation(description: "register")
        
        RegisterService.instance.register(withEmail: userData.email, withPassword: userData.password, withUsername: userData.username) { result in
            switch result {
            case .success(let uid):
                ListsUser.instance.createListsForUser(uid, withOnComplete: { result in
                    switch result {
                    case .success:
                        onSuccess(uid)
                    case .failure(_):
                        onFailure(RegisterServiceError.unknown)
                    }
                    registerExp.fulfill()
                })
            case .failure(let error):
                onFailure(error)
                registerExp.fulfill()
            }
        }
        
        helperTestCase.waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    static func deleteUserCompletely(_ userData: UserData) {
        let deleteExp = helperTestCase.expectation(description: "delete user and all related content")
        ListsUser.instance.deleteLoggedInUserCompletely(userData.username) {
            deleteExp.fulfill()
        }
        helperTestCase.waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
