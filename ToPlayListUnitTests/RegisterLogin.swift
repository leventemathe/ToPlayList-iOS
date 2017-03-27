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

typealias UserData = (username: String, email: String, password: String)

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
        RegisterLoginTestHelper.register(userData, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataNoUsername, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataNoEmail, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataWeakPassword, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataWrongEmail1, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataWrongEmail2, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataWrongEmail3, withOnSuccess: {
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
        RegisterLoginTestHelper.register(userDataWeakPassword, withOnSuccess: {
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
    
    //TODO add more failing login AND register tests
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
        RegisterLoginTestHelper.login(userData, withOnSuccess: {
            XCTAssertTrue(true, "Logged in succesfully")
        }, withOnFailure: { error in
            XCTAssertTrue(false, "Login failed")
        })
    }
}



struct RegisterLoginTestHelper {
    
    static  let helperTestCase = XCTestCase()
    
    static func login(_ userData: UserData, withOnSuccess onSuccess: @escaping ()->(), withOnFailure onFailure: @escaping (LoginServiceError)->()) {
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
    
    static func register(_ userData: UserData, withOnSuccess onSuccess: @escaping ()->(), withOnFailure onFailure: @escaping (RegisterServiceError)->()) {
        let registerExp = helperTestCase.expectation(description: "register")
        
        RegisterService.instance.register(withEmail: userData.email, withPassword: userData.password, withUsername: userData.username) { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onFailure(error)
            }
            registerExp.fulfill()
        }
        
        helperTestCase.waitForExpectations(timeout: 10) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}


