//
//  ToPlayListUITests.swift
//  ToPlayListUITests
//
//  Created by Máthé Levente on 2017. 03. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest

class RegisterLogin: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func registerShouldWork() {
        
        let app = XCUIApplication()
        app.textFields["username"].typeText("levi")
        app.textFields["email"].typeText("levi@levi.com")
        app.secureTextFields["password"].typeText("evi")
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).buttons["Register"].tap()
        
    }
    
}
