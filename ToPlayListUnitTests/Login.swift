//
//  Login.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayList
@testable import Firebase

class LoginSuccesful: XCTestCase {
    
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    
    override func setUp() {
        super.setUp()
        RegisterLoginTestHelper.register(userData, withOnSuccess: { _ in }, withOnFailure: {_ in })
    }
    
    override func tearDown() {
        RegisterLoginTestHelper.deleteUserCompletely(userData)
        super.tearDown()
    }
    
    func testLoginSuccesful() {
        RegisterLoginTestHelper.login(userData, withOnSuccess: {
            XCTAssertTrue(true, "Logged in succesfully")
        }, withOnFailure: { error in
            XCTAssertTrue(false, "Login failed")
        })
    }
}

class LoginAlreadyExists: XCTestCase {
    
}

class LoginFailing: XCTestCase {
    
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    
    private let userDataNoEmail = (username: "levi", email: "", password: "levilevi")
    private let userDataNoPassword = (username: "levi", email: "levi@levi.com", password: "")
    private let userDataWrongEmail1 = (username: "levi", email: "levi@com", password: "levilevi")
    private let userDataWrongEmail2 = (username: "levi", email: "levi.com", password: "levilevi")
    private let userDataWrongEmail3 = (username: "levi", email: "levicom", password: "levilevi")
    private let userDataWrongPassword = (username: "levi", email: "levi@levi.com", password: "levi")
    
    override func setUp() {
        super.setUp()
        RegisterLoginTestHelper.register(userData, withOnSuccess: { _ in }, withOnFailure: {_ in })
    }
    
    override func tearDown() {
        RegisterLoginTestHelper.deleteUserCompletely(userData)
        super.tearDown()
    }
    
    func testLoginNoEmail() {
        RegisterLoginTestHelper.login(userDataNoEmail, withOnSuccess: {
            XCTAssertTrue(false, "Login Succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Login failed no email")
            default:
                XCTAssertTrue(false, "Login failed with wrong error")
            }
        })
    }
    
    func testLoginNoPassword() {
        RegisterLoginTestHelper.login(userDataNoPassword, withOnSuccess: {
            XCTAssertTrue(false, "Login Succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidPassword:
                XCTAssertTrue(true, "Login failed no password")
            default:
                XCTAssertTrue(false, "Login failed with wrong error")
            }
        })
    }
    
    func testLoginWrongEmail1() {
        RegisterLoginTestHelper.login(userDataWrongEmail1, withOnSuccess: {
            XCTAssertTrue(false, "Login Succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Login failed wrong email")
            case .userNotFound:
                XCTAssertTrue(true, "Login failed no user found with email")
            default:
                XCTAssertTrue(false, "Login failed with wrong error")
            }
        })
    }
    
    func testLoginWrongEmail2() {
        RegisterLoginTestHelper.login(userDataWrongEmail2, withOnSuccess: {
            XCTAssertTrue(false, "Login Succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Login failed wrong email")
            default:
                XCTAssertTrue(false, "Login failed with wrong error")
            }
        })
    }
    
    func testLoginWrongEmail3() {
        RegisterLoginTestHelper.login(userDataWrongEmail3, withOnSuccess: {
            XCTAssertTrue(false, "Login Succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Login failed wrong email")
            default:
                XCTAssertTrue(false, "Login failed with wrong error")
            }
        })
    }
    
    func testLoginWrongPassword() {
        RegisterLoginTestHelper.login(userDataWrongPassword, withOnSuccess: {
            XCTAssertTrue(false, "Login Succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidPassword:
                XCTAssertTrue(true, "Login failed wrong password")
            default:
                XCTAssertTrue(false, "Login failed with wrong error")
            }
        })
    }
}




