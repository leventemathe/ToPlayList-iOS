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

class RegisterSuccesful: XCTestCase {
 
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

class RegisterFailing: XCTestCase {
    
    private let userDataNoUsername = (username: "", email: "levi@levi.com", password: "levilevi")
    private let userDataNoEmail = (username: "levi", email: "", password: "levilevi")
    private let userDataNoPassword = (username: "levi", email: "levi@levi.com", password: "")
    private let userDataWrongEmail1 = (username: "levi", email: "levi@com", password: "levilevi")
    private let userDataWrongEmail2 = (username: "levi", email: "levi.com", password: "levilevi")
    private let userDataWrongEmail3 = (username: "levi", email: "levicom", password: "levilevi")
    private let userDataWeakPassword = (username: "levi", email: "levi@levi.com", password: "levi")
    
    func testRegisterNoUsername() {
        let registerExp = expectation(description: "register with no username")
        
        RegisterService.instance.register(withEmail: userDataNoUsername.email, withPassword: userDataNoUsername.password, withUsername: userDataNoUsername.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .invalidUsername:
                    XCTAssertTrue(true, "Registration failed with invalid username")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRegisterNoEmail() {
        let registerExp = expectation(description: "register with no email")
        
        RegisterService.instance.register(withEmail: userDataNoEmail.email, withPassword: userDataNoEmail.password, withUsername: userDataNoEmail.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .invalidEmail:
                    XCTAssertTrue(true, "Registration failed with invalid email")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRegisterNoPassword() {
        let registerExp = expectation(description: "register with no password")
        
        RegisterService.instance.register(withEmail: userDataNoPassword.email, withPassword: userDataNoPassword.password, withUsername: userDataNoPassword.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .passwordTooWeak:
                    XCTAssertTrue(true, "Registration failed with no password")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRegisterWrongEmail1() {
        let registerExp = expectation(description: "register with wrong email 1")
        
        RegisterService.instance.register(withEmail: userDataWrongEmail1.email, withPassword: userDataWrongEmail1.password, withUsername: userDataWrongEmail1.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .invalidEmail:
                    XCTAssertTrue(true, "Registration failed with invalid email 1")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRegisterWrongEmail2() {
        let registerExp = expectation(description: "register with wrong email 2")
        
        RegisterService.instance.register(withEmail: userDataWrongEmail2.email, withPassword: userDataWrongEmail2.password, withUsername: userDataWrongEmail2.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .invalidEmail:
                    XCTAssertTrue(true, "Registration failed with invalid email 2")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRegisterWrongEmail3() {
        let registerExp = expectation(description: "register with wrong email 3")
        
        RegisterService.instance.register(withEmail: userDataWrongEmail3.email, withPassword: userDataWrongEmail3.password, withUsername: userDataWrongEmail3.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .invalidEmail:
                    XCTAssertTrue(true, "Registration failed with invalid email 3")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
            }
            registerExp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testRegisterWeakPassword() {
        let registerExp = expectation(description: "register with weak password")
        
        RegisterService.instance.register(withEmail: userDataWeakPassword.email, withPassword: userDataWeakPassword.password, withUsername: userDataWeakPassword.username) { result in
            switch result {
            case .success:
                XCTAssertTrue(false, "Registration succesful")
            case .failure(let error):
                switch error {
                case .passwordTooWeak:
                    XCTAssertTrue(true, "Registration failed with weak password")
                default:
                    XCTAssertTrue(false, "Registration failed with wrong error")
                }
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



class RegisterAlreadyExists: XCTestCase {
    
}


class LoginSuccesful: XCTestCase {
    
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
