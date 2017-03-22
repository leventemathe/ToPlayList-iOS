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
