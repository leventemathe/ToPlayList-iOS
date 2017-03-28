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

//TODO Invalid key in object. Keys must be non-empty and cannot contain '.' '#' '$' '[' or ']''

class LoggedInUserCleanup: XCTestCase {
    
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    private var uid: String!
    
    override func setUp() {
        super.setUp()
        RegisterLoginTestHelper.register(userData, withOnSuccess: { result in
            XCTAssertTrue(result != nil)
            self.uid = result
            XCTAssertTrue(true, "registration succesful")
        }, withOnFailure: { error in
            XCTAssertTrue(true, "registration failed")
        })
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

class RegisterSuccesful: XCTestCase {
 
    private let userData = (username: "levi", email: "levi@levi.com", password: "levilevi")
    
    override func tearDown() {
        RegisterLoginTestHelper.deleteUserCompletely(userData)
        super.tearDown()
    }
    
    func testRegisterSuccesful() {
        RegisterLoginTestHelper.register(userData, withOnSuccess: {_ in 
            XCTAssertTrue(true, "Registration succesful")
        }, withOnFailure: { error in
            XCTAssertTrue(false, "Registration failed")
        })
    }
}

class RegisterFailing: XCTestCase {
    
    private let userDataNoUsername = (username: "", email: "levi@levi.com", password: "levilevi")
    private let userDataNoEmail = (username: "levi", email: "", password: "levilevi")
    private let userDataNoPassword = (username: "levi", email: "levi@levi.com", password: "")
    private let userDataWrongEmail1 = (username: "levi", email: "levi@com", password: "levilevi")
    private let userDataWrongEmail2 = (username: "levi", email: "levi.com", password: "levilevi")
    private let userDataWrongEmail3 = (username: "levi", email: "levicom", password: "levilevi")
    private let userDataWeakPassword = (username: "levi", email: "levi@levi.com", password: "levi")
    
    func testRegisterNoUsername() {
        RegisterLoginTestHelper.register(userDataNoUsername, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidUsername:
                XCTAssertTrue(true, "Registration failed with no username")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
    
    func testRegisterNoEmail() {
        RegisterLoginTestHelper.register(userDataNoEmail, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Registration failed with invalid email")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
    
    func testRegisterNoPassword() {
        RegisterLoginTestHelper.register(userDataWeakPassword, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .passwordTooWeak:
                XCTAssertTrue(true, "Registration failed with no password")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
    
    func testRegisterWrongEmail1() {
        RegisterLoginTestHelper.register(userDataWrongEmail1, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Registration failed with invalid email")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
    
    func testRegisterWrongEmail2() {
        RegisterLoginTestHelper.register(userDataWrongEmail2, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Registration failed with invalid email")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
    
    func testRegisterWrongEmail3() {
        RegisterLoginTestHelper.register(userDataWrongEmail3, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .invalidEmail:
                XCTAssertTrue(true, "Registration failed with invalid email")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
    
    func testRegisterWeakPassword() {
        RegisterLoginTestHelper.register(userDataWeakPassword, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .passwordTooWeak:
                XCTAssertTrue(true, "Registration failed weak password")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error")
            }
        })
    }
}



class RegisterAlreadyExists: XCTestCase {
    
}





