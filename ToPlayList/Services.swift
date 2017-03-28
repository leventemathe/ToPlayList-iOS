//
//  Services.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 21..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase

typealias OptionalUserData = (email: String?, password: String?, username: String?)
typealias UserData = (email: String, password: String, username: String)

typealias OptionalUserDataLogin = (email: String?, password: String?)
typealias UserDataLogin = (email: String, password: String)

enum RegisterServiceResult {
    case success(String)
    case failure(RegisterServiceError)
}

enum RegisterServiceError {
    case emailAlreadyInUse
    case usernameAlreadyInUse
    case invalidUsername
    case invalidEmail
    case noInternet
    case passwordTooWeak
    case unknown
}

enum RegisterValidationResult {
    case success(UserData)
    case failure(RegisterValidationError)
}

enum RegisterValidationError {
    case noUserData
    case noUsername
    case noEmail
    case noPassword
}

// TODO recheck error codes
class RegisterService {
    
    static let instance = RegisterService()
    
    private init() {}
    
    // TODO get rid of special chars, check type and length, sync with Firebase secu rules -> unit tests
    func validate(_ userData: OptionalUserData) -> RegisterValidationResult {
        guard var email = userData.email, var password = userData.password, var username = userData.username else {
            return .failure(.noUserData)
        }
        
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if username == "" {
            print("no username")
            return .failure(.noUsername)
        }
        if email == "" {
            print("no email")
            return .failure(.noEmail)
        }
        if password == "" {
            print("no password")
            return .failure(.noPassword)
        }
        
        return .success((email: email, password: password, username: username))
    }
    
    func register(withEmail email: String, withPassword password: String, withUsername username: String, withOnComplete onComplete: @escaping (RegisterServiceResult)->()) {
        if username == "" {
            onComplete(.failure(.invalidUsername))
            return
        }
        if email == "" {
            onComplete(.failure(.invalidEmail))
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = FIRAuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .errorCodeEmailAlreadyInUse:
                    onComplete(.failure(.emailAlreadyInUse))
                    break
                case .errorCodeInvalidEmail:
                    onComplete(.failure(.invalidEmail))
                    break
                case .errorCodeNetworkError:
                    onComplete(.failure(.noInternet))
                    break
                case .errorCodeWeakPassword:
                    onComplete(.failure(.passwordTooWeak))
                    break
                default:
                    onComplete(.failure(.unknown))
                    break
                }
            } else {
                self.addUserDataToDatabase(user!.uid, withUsername: username, withOnComplete: onComplete)
            }
        }
    }
    
    private func addUserDataToDatabase(_ uid: String, withUsername username: String, withOnComplete onComplete: @escaping (RegisterServiceResult)->()) {
        ListsUser.instance.createUserFromAuthenticated({ result in
            switch result {
            case .success:
                onComplete(.success(uid))
            case .failure(let error):
                ListsUser.instance.deleteLoggedInUserBeforeFullyCreated()
                switch error {
                case .usernameAlreadyInUse:
                    onComplete(.failure(.usernameAlreadyInUse))
                case .unknownError:
                    onComplete(.failure(.unknown))
                }
            }
        }, withUsername: username)
    }
}



enum LoginServiceResult {
    case success
    case failure(LoginServiceError)
}

enum LoginServiceError {
    case userNotFound
    case invalidEmail
    case invalidPassword
    case noInternet
    case userTokenExpired
    case unknown
}

enum LoginValidationResult {
    case success(UserDataLogin)
    case failure(LoginValidationError)
}

enum LoginValidationError {
    case noUserData
    case noEmail
    case noPassword
}

// TODO recheck error codes!
class LoginService {
 
    static let instance = LoginService()
    
    private init() {}
    
    // TODO get rid of special chars, check type and length, sync with Firebase secu rules -> unit tests
    func validate(_ userData: OptionalUserDataLogin) -> LoginValidationResult {
        guard var email = userData.email, var password = userData.password else {
            return .failure(.noUserData)
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email == "" {
            return .failure(.noEmail)
        }
        if password == "" {
            return .failure(.noPassword)
        }
        
        return .success((email: email, password: password))
    }
    
    func login(_ email: String, withPassword password: String, withOnComplete onComplete: @escaping (LoginServiceResult)->()) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = FIRAuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .errorCodeUserNotFound:
                    onComplete(.failure(.userNotFound))
                    break
                case .errorCodeInvalidEmail:
                    onComplete(.failure(.invalidEmail))
                    break
                case .errorCodeNetworkError:
                    onComplete(.failure(.noInternet))
                    break
                case .errorCodeUserTokenExpired:
                    onComplete(.failure(.userTokenExpired))
                    break
                case .errorCodeWrongPassword:
                    onComplete(.failure(.invalidPassword))
                    break
                default:
                    onComplete(.failure(.unknown))
                    break
                }
            } else {
                onComplete(.success)
            }
        }
    }
}











