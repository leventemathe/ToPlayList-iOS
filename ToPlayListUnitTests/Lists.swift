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

class RegisterLogin: XCTestCase {
 
    private let userData = ["username": "levi", "email": "levi@levi.com", "password": "levilevi"]
    
    override func setUp() {
        super.setUp()
        FIRApp.configure()
    }
    
    override func tearDown() {
        //ListsUser.instance.deleteUserCompletely()
        super.tearDown()
    }
    
    func testRegister() {
        FIRAuth.auth()?.createUser(withEmail: userData["email"]!, password: userData["password"]!, completion: { (user, error) in
            //XCTAssertTrue(error == nil)
            
            ListsUser.instance.createUserFromAuthenticated({ result in
                switch result {
                case .failure(_):
                    //XCTAssertTrue(false)
                    break
                case .success:
                    //XCTAssertTrue(true)
                    break
                }
            }, withUsername: self.userData["username"]!)
        })
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
