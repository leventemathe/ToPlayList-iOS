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

//TODO Invalid key in object. Keys must be non-empty and cannot contain '.' '#' '$' '[' or ']'

class RegisterValidationSuccessful: XCTestCase {
    
    private let userData: UserDataOptional = (email: "levi@levi.com", password: "Llevilevi1", username: "levi")
    
    func testRegisterValidationSuccesful() {
        let result = RegisterService.instance.validate(userData)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
}

// tests app-level errors and security/validation rules
class RegisterValidationFailed: XCTestCase {
    
    private let userDataNoUsername: UserDataOptional = (email: "levi@levi.com", password: "levilevi", username: "")
    private let userDataNoEmail: UserDataOptional = (email: "", password: "levilevi", username: "levi")
    private let userDataNoPassword: UserDataOptional = (email: "levi@levi.com", password: "", username: "levi")
    private let userDataWrongEmail1: UserDataOptional = (email: "levi@com", password: "levilevi", username: "levi")
    private let userDataWrongEmail2: UserDataOptional = (email: "levi.com", password: "levilevi", username: "levi")
    private let userDataWrongEmail3: UserDataOptional = (email: "levicom", password: "levilevi", username: "levi")
    private let userDataWeakPassword: UserDataOptional = (email: "levi@levi.com", password: "levi", username: "levi")
    
    func testRegisterValidationNoUsername() {
        let result = RegisterService.instance.validate(userDataNoUsername)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .noUsername:
                XCTAssertTrue(true, "validation failed no username")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationNoEmail() {
        let result = RegisterService.instance.validate(userDataNoEmail)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .noEmail:
                XCTAssertTrue(true, "validation failed no email")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationNoPassword() {
        let result = RegisterService.instance.validate(userDataNoPassword)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .noPassword:
                XCTAssertTrue(true, "validation failed no password")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
}

// tests the cleanup function that removes the user data from firebase, that was used for the test
class LoggedInUserCleanup: XCTestCase {
    
    private let userData = (email: "levi@levi.com", password: "levilevi", username: "levi")
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
 
    private let userData = (email: "levi@levi.com", password: "levilevi", username: "levi")
    
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

// tests Firebase-level errors and security/validation rules
class RegisterFailing: XCTestCase {
    
    private let userDataNoUsername = (email: "levi@levi.com", password: "levilevi", username: "")
    private let userDataNoEmail = (email: "", password: "levilevi", username: "levi")
    private let userDataNoPassword = (email: "levi@levi.com", password: "", username: "levi")
    private let userDataWrongEmail1 = (email: "levi@com", password: "levilevi", username: "levi")
    private let userDataWrongEmail2 = (email: "levi.com", password: "levilevi", username: "levi")
    private let userDataWrongEmail3 = (email: "levicom", password: "levilevi", username: "levi")
    private let userDataWeakPassword = (email: "levi@levi.com", password: "levi", username: "levi")
    
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




