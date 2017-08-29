//
//  Lists.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import ToPlayListDev
@testable import Firebase

// app level validation
class RegisterValidationSuccessful: XCTestCase {
    
    private let userData: UserDataOptional = (email: "levi@levi.com", password: "Llevilevi1", username: "levi")
    private let userData2: UserDataOptional = (email: "levi@levi.com", password: "Llevilevi1", username: "levi:) 😀🐴⚽️⏰")
    private let userData3: UserDataOptional = (email: "levi@levi.com", password: "Llevilevi1", username: "éáú")
    private let userData4: UserDataOptional = (email: "levi@levi.com", password: "LlevASDilevi123", username: "éáú")
    
    private let userDataSpacesInUsername: UserDataOptional = (email: "levi@levi.com", password: "LlevASDilevi123", username: "levi m")
    private let userDataSpacesInPassword: UserDataOptional = (email: "levi@levi.com", password: "LlevASDilevi123", username: "levi m")
    
    private let userDataGibberishInPassword: UserDataOptional = (email: "levi@levi.com", password: "L#&😊🥝⊇Séálevi123", username: "levi m")
    
    func testRegisterValidationSuccesful() {
        let result = RegisterService.instance.validate(userData)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
    
    func testRegisterValidationSuccesful2() {
        let result = RegisterService.instance.validate(userData2)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
    
    func testRegisterValidationSuccesful3() {
        let result = RegisterService.instance.validate(userData3)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
    
    func testRegisterValidationSuccesful4() {
        let result = RegisterService.instance.validate(userData4)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
    
    func testRegisterValidationSuccesfulSpacesInUsername() {
        let result = RegisterService.instance.validate(userDataSpacesInUsername)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
    
    func testRegisterValidationSuccesfulSpacesInPassword() {
        let result = RegisterService.instance.validate(userDataSpacesInPassword)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
    
    func testRegisterValidationSuccesfulGibberishInPassword() {
        let result = RegisterService.instance.validate(userDataGibberishInPassword)
        switch result {
        case .success(_):
            XCTAssertTrue(true, "validation successful")
        case .failure(_):
            XCTAssertTrue(false, "validation failed")
        }
    }
}

class RegisterValidationFailed: XCTestCase {
    
    private let userDataNoUsername: UserDataOptional = (email: "levi@levi.com", password: "Levilevi1", username: "")
    private let userDataNoEmail: UserDataOptional = (email: "", password: "Levilevi1", username: "levi")
    private let userDataNoPassword: UserDataOptional = (email: "levi@levi.com", password: "", username: "levi")
    
    private let userDataWrongEmail1: UserDataOptional = (email: "levi@com", password: "Levilevi1", username: "levi")
    private let userDataWrongEmail2: UserDataOptional = (email: "levi.com", password: "Levilevi1", username: "levi")
    private let userDataWrongEmail3: UserDataOptional = (email: "levicom", password: "Levilevi1", username: "levi")
    
    private let userDataWeakPassword: UserDataOptional = (email: "levi@levi.com", password: "levi", username: "levi")
    
    private let userDataForbiddenCharsInUsername: UserDataOptional = (email: "levi@levi.com", password: "Levilevi1", username: "levi[]")
    private let userDataForbiddenCharsInUsername2: UserDataOptional = (email: "levi@levi.com", password: "Levilevi1", username: "levi#")
    private let userDataForbiddenCharsInUsername3: UserDataOptional = (email: "levi@levi.com", password: "Levilevi1", username: "levi.")
    private let userDataForbiddenCharsInUsername4: UserDataOptional = (email: "levi@levi.com", password: "Levilevi1", username: "levi$$$$")
    
    private let userDataForbiddenCharsInEmail: UserDataOptional = (email: "levi,asd@levi.com", password: "Levilevi1", username: "levi")
    private let userDataForbiddenCharsInEmail2: UserDataOptional = (email: "leviéáasd@levi.com", password: "Levilevi1", username: "levi")
    private let userDataForbiddenCharsInEmail3: UserDataOptional = (email: "levi❤️🏀sd@levi.com", password: "Levilevi1", username: "llevi")
    private let userDataForbiddenCharsInEmail4: UserDataOptional = (email: "lev i@levi.com", password: "LlevASDilevi123", username: "llevi")
    
    private let userDataUsernameTooLong: UserDataOptional = (email: "levi@levi.com", password: "Levilevi1", username: "leviafsdgskjsaagjsfngbsfngbjsnbkjfsdnbjkdfnbkdbnkdnbkdnjbdnbkdnbkjsgfdsgdfghdghfghfjfhjhjgnbcvx")
    private let userDataEmailTooLong: UserDataOptional = (email: "levileviafsdgskjsaagjsfngbsfngbjsnbkjfsdnbjkdfnbkdbnkdnbkdnjbdnbkdnbkjsgfdsgdfghdghfghfjfhjhjgnbcvxhfkjhfkhfknmkfmbdmbfgmbnkmbcvmvlshjjkbkbvklmbxnbxvlblevileviafsdgskjsaagjsfngbsfngbjsnbkjfsdnbjkdfnbkdbnkdnbkdnjbdnbkdnbkjsgfdsgdfghdghfghfjfhjhjgnbcvxhfkjhfkhfknmkfmbdmbfgmbnkmbcvmvlshjjkbkbvklmbxnbxvlblevileviafsdgskjsaagjsfngbsfngbjsnbkjfsdnbjkdfnbkdbnkdnbkdnjbdnbkdnbkjsgfdsgdfghdghfghfjfhjhjgnbcvxhfkjhfkhfknmkfmbdmbfgmbnkmbcvmvlshjjkbkbvklmbxnbxvlblevileviafsdgskjsaagjsfngbsfngbjsnbkjfsdnbjkdfnbkdbnkdnbkdnjbdnbkdnbkjsgfdsgdfghdghfghfjfhjhjgnbcvxhfkjhfkhfknmkfmbdmbfgmbnkmbcvmvlshjjkbkbvklmbxnbxvlb@levi.com", password: "Levilevi1", username: "levi")
    private let userDataPasswordTooShort: UserDataOptional = (email: "leviasd@levi.com", password: "Li1", username: "levi")
    private let userDataPasswordTooLong: UserDataOptional = (email: "leviasd@levi.com", password: "L1leviafgsfmgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhL1leviafgsfmgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhL1leviafgsfmgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhL1leviafgsfmgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjhgbdgjkbnmnbmnbjknbmcvnbmxbkjnnbcbcxvbvxcmcxnvmbblkhdjh", username: "levi")
    
    private let userDataPasswordNoCapital: UserDataOptional = (email: "levi@levi.com", password: "levilevi1", username: "levi")
    private let userDataPasswordNoNumber: UserDataOptional = (email: "levi@levi.com", password: "Levilevi", username: "levi")
    
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
    
    func testRegisterValidationForbiddenCharsInUsername() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInUsername)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .forbiddenCharacterInUsername(_):
                XCTAssertTrue(true, "validation failed forbidden char in username")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInUsername2() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInUsername2)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .forbiddenCharacterInUsername(_):
                XCTAssertTrue(true, "validation failed forbidden char in username")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInUsername3() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInUsername3)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .forbiddenCharacterInUsername(_):
                XCTAssertTrue(true, "validation failed forbidden char in username")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInUsername4() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInUsername4)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .forbiddenCharacterInUsername(_):
                XCTAssertTrue(true, "validation failed forbidden char in username")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInEmail() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInEmail)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .invalidEmail(_):
                XCTAssertTrue(true, "validation failed forbidden char in email")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInEmail2() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInEmail2)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .invalidEmail(_):
                XCTAssertTrue(true, "validation failed forbidden char in email")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInEmail3() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInEmail3)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .invalidEmail(_):
                XCTAssertTrue(true, "validation failed forbidden char in email")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationForbiddenCharsInEmail4() {
        let result = RegisterService.instance.validate(userDataForbiddenCharsInEmail4)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .invalidEmail(_):
                XCTAssertTrue(true, "validation failed forbidden char in email")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationUsernameTooLong() {
        let result = RegisterService.instance.validate(userDataUsernameTooLong)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .tooLongUsername(_):
                XCTAssertTrue(true, "validation failed username too long")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationEmailTooLong() {
        let result = RegisterService.instance.validate(userDataEmailTooLong)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .tooLongEmail(_):
                XCTAssertTrue(true, "validation failed email too long")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationPasswordTooLong() {
        let result = RegisterService.instance.validate(userDataPasswordTooLong)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .tooLongPassword(_):
                XCTAssertTrue(true, "validation failed password too long")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationPasswordTooShort() {
        let result = RegisterService.instance.validate(userDataPasswordTooShort)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .tooShortPassword(_):
                XCTAssertTrue(true, "validation failed password too short")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationPasswordNoCapital() {
        let result = RegisterService.instance.validate(userDataPasswordNoCapital)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .noCapitalInPassword(_):
                XCTAssertTrue(true, "validation failed no capital in password")
            default:
                XCTAssertTrue(false, "validation failed other error")
            }
        }
    }
    
    func testRegisterValidationPasswordNoNumber() {
        let result = RegisterService.instance.validate(userDataPasswordNoNumber)
        switch result {
        case .success(_):
            XCTAssertTrue(false, "validation successful")
        case .failure(let error):
            switch error {
            case .noNumberInPassword(_):
                XCTAssertTrue(true, "validation failed no number in password")
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
            XCTAssertTrue(false, "registration failed")
        })
    }
    
    func testDeleteLoggedInUserCompletely() {
        let deleteExp = expectation(description: "delete registered content for testDeleteLoggedInUserCompletely")
        ListsUser.instance.deleteLoggedInUserCompletely(userData.username) {
            deleteExp.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                XCTAssertTrue(false, "deleting user failed with error: \(error.localizedDescription)")
            }
            XCTAssertTrue(true, "user deleted succesfully")
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
            XCTAssertTrue(false, "Registration failed with error: \(error)")
        })
    }
}

class RegisterFailing: XCTestCase {
    
    private let userDataNoUsername = (email: "levi@levi.com", password: "levilevi", username: "")
    private let userDataNoEmail = (email: "", password: "levilevi", username: "levi")
    private let userDataNoPassword = (email: "levi@levi.com", password: "", username: "levi")
    private let userDataTooLongUsername = (email: "levi@levi.com", password: "levilevi", username: "123456789abcqweqwet")
    private let userDataInvalidCharsInUsername = (email: "levi@levi.com", password: "LeviLevi123", username: "levi[]")
    private let userDataInvalidCharsInUsername2 = (email: "levi@levi.com", password: "LeviLevi123", username: "levi#123")
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
    
    func testRegisterTooLongUsername() {
        RegisterLoginTestHelper.register(userDataTooLongUsername, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .usernameAlreadyInUse:
                // this is also accepted, because the error is just an Error?, no way to tell which validation rule failed
                XCTAssertTrue(true, "Registration failed with username already in use")
            case .permissionDenied:
                XCTAssertTrue(true, "Registration failed with permissions denied")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error: \(error)")
            }
        })
    }
    
    func testRegisterInvalidCharInUsername1() {
        RegisterLoginTestHelper.register(userDataInvalidCharsInUsername, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .permissionDenied:
                XCTAssertTrue(true, "Registration failed with permissions denied")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error: \(error)")
            }
        })
    }
    
    func testRegisterInvalidCharInUsername2() {
        RegisterLoginTestHelper.register(userDataInvalidCharsInUsername2, withOnSuccess: {_ in
            XCTAssertTrue(false, "Registration succesful")
        }, withOnFailure: { error in
            switch error {
            case .permissionDenied:
                XCTAssertTrue(true, "Registration failed with permissions denied")
            default:
                XCTAssertTrue(false, "Registration failed with wrong error: \(error)")
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
    
    private let existingUser = (email: "levi@levi.com", password: "levilevi", username: "levi")
    private let emailAlreadyExistsUser = (email: "levi@levi.com", password: "levilevi", username: "levi2")
    private let userNameAlreadyExistsUser = (email: "levi2@levi.com", password: "levilevi", username: "levi")
    
    override func setUp() {
        super.setUp()
        RegisterLoginTestHelper.register(existingUser, withOnSuccess: {_ in
            XCTAssertTrue(true, "Registration succesful")
        }, withOnFailure: { error in
            XCTAssertTrue(false, "Registration failed with error: \(error)")
        })
        RegisterLoginTestHelper.logout()
    }
    
    override func tearDown() {
        RegisterLoginTestHelper.login((email: existingUser.email, password: existingUser.password), withOnSuccess: {_ in}, withOnFailure: {_ in})
        RegisterLoginTestHelper.deleteUserCompletely(existingUser)
        super.tearDown()
    }
    
    func testEmailAlreadyExists() {
        RegisterLoginTestHelper.register(emailAlreadyExistsUser, withOnSuccess: { result in
            XCTAssertTrue(false, "Register was succesful with already existing email")
        }, withOnFailure: { error in
            switch error {
            case .emailAlreadyInUse:
                XCTAssertTrue(true, "Registration failed because email already exists")
            default:
                XCTAssertTrue(false, "Registration failed because of wrong reason")
            }
        })
    }
    
    func testUsernameExists() {
        RegisterLoginTestHelper.register(userNameAlreadyExistsUser, withOnSuccess: { result in
            XCTAssertTrue(false, "Register was succesful with already existing username")
        }, withOnFailure: { error in
            switch error {
            case .usernameAlreadyInUse:
                XCTAssertTrue(true, "Registration failed because username already exists")
            case .permissionDenied:
                XCTAssertTrue(true, "Registration failed because permission was denied")
            default:
                XCTAssertTrue(false, "Registration failed because of wrong reason")
            }
        })
    }
}




