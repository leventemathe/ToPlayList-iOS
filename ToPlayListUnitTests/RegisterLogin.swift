//
//  Lists.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayList
@testable import Firebase

class LoggedInUserCleanup: XCTestCase {
    
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    private var uid: String?
    
    override func setUp() {
        super.setUp()
        let registerExp = expectation(description: "register setup for testDeleteLoggedInUserCompletely")
        RegisterService.instance.register(withEmail: userData.email, withPassword: userData.password, withUsername: userData.username) { result in
            switch result {
            case .success(let uid):
                XCTAssertTrue(true, "Registration succesful")
                self.uid = uid
            case .failure(_):
                XCTAssertTrue(false, "Registration failed")
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testDeleteLoggedInUserCompletely() {
        guard let uid = self.uid else {
            XCTAssertTrue(false, "testDeleteLoggedInUserCompletely failed, no user is logged in")
            return
        }
        // delete the user
        let deleteExp = expectation(description: "delete registered content for testDeleteLoggedInUserCompletely")
        ListsUser.instance.deleteLoggedInUserCompletely(userData.username) {
            deleteExp.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        // check if deletion worked
        let userExp = expectation(description: "trying to get user for testDeleteLoggedInUserCompletely")
        let usernameExp = expectation(description: "trying to get username for testDeleteLoggedInUserCompletely")
        let listsExp = expectation(description: "trying to get lists for testDeleteLoggedInUserCompletely")
        
        ListsEndpoints.USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            XCTAssert(!snapshot.exists(), "user was nil for testDeleteLoggedInUserCompletely")
            userExp.fulfill()
        })
        ListsEndpoints.USERNAMES.child(userData.username).observeSingleEvent(of: .value, with: { snapshot in
            XCTAssert(!snapshot.exists(), "username was nil for testDeleteLoggedInUserCompletely")
            usernameExp.fulfill()
        })
        ListsEndpoints.LISTS.queryOrdered(byChild: ListsEndpoints.List.USERID).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
            XCTAssert(!snapshot.exists(), "lists were nil for testDeleteLoggedInUserCompletely")
            listsExp.fulfill()
        })
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

class Register: XCTestCase {
 
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        let deleteExp = expectation(description: "delete registered content")
        ListsUser.instance.deleteLoggedInUserCompletely(userData.username) {
            deleteExp.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        super.tearDown()
    }
    
    func testRegisterSuccesful() {
        let registerExp = expectation(description: "register")
        
        RegisterService.instance.register(withEmail: userData.email, withPassword: userData.password, withUsername: userData.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Registration succesful")
            case .failure(_):
                XCTAssertTrue(false, "Registration failed")
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

class Login: XCTestCase {
    
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    
    override func setUp() {
        super.setUp()
        let registerExp = expectation(description: "register setup for login")
        RegisterService.instance.register(withEmail: userData.email, withPassword: userData.password, withUsername: userData.username) { result in
            do {
                try FIRAuth.auth()?.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            registerExp.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    override func tearDown() {
        let deleteExp = expectation(description: "delete registered + logged in content")
        ListsUser.instance.deleteLoggedInUserCompletely(userData.username) {
            deleteExp.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        super.tearDown()
    }
    
    func testLoginSuccesful() {
        let loginExp = expectation(description: "login")
        
        LoginService.instance.login(userData.email, withPassword: userData.password) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Login succesful")
            case .failure(_):
                XCTAssertTrue(false, "Login failed")
            }
            loginExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
