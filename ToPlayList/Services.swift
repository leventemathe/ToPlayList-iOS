//
//  Services.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 21..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase

enum RegisterServiceResult {
    case success
    case failure(RegisterServiceError)
}

enum RegisterServiceError {
    case emailAlreadyInUse
    case usernameAlreadyInUse
    case invalidEmail
    case noInternet
    case passwordTooWeak
    case unknown
}

// TODO recheck error codes
class RegisterService {
    
    static let instance = RegisterService()
    
    private init() {}
    
    func register(withEmail email: String, withPassword password: String, withUsername username: String, withOnComplete onComplete: @escaping (RegisterServiceResult)->()) {
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
                self.addUserDataToDatabase(username, withOnComplete: onComplete)
            }
        }
    }
    
    private func addUserDataToDatabase(_ username: String, withOnComplete onComplete: @escaping (RegisterServiceResult)->()) {
        ListsUser.instance.createUserFromAuthenticated({ result in
            switch result {
            case .success:
                onComplete(.success)
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

// TODO recheck error codes!
class LoginService {
 
    static let instance = LoginService()
    
    private init() {}
    
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











