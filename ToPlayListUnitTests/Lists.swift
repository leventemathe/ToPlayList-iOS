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
        FIRApp.configure()
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

class Lists: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {

        super.tearDown()
    }
   
    func testAddGameToToPlayList() {
        
    }
    
}
