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
    case tooManyRequests
    case passwordTooWeak
    case permissionDenied
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
    case forbiddenCharacterInUsername(String)
    case tooLongUsername
    case tooLongEmail
    case tooLongPassword
    case tooShortPassword
    case invalidEmail
    case noNumberInPassword
    case noCapitalInPassword
}

class RegisterService {
    
    static let instance = RegisterService()
    
    private init() {}
    
    static let USERNAME_FORBIDDEN_CHARACTERS = [".", "#", "$", "[", "]", "/"] //TODO add more?
    static let USERNAME_MAX_LENGTH = 15
    static let EMAIL_MAX_LENGTH = 254
    static let PASSWORD_MIN_LENGTH = 6
    static let PASSWORD_MAX_LENGTH = 254
    
    func validate(_ userData: OptionalUserData) -> RegisterValidationResult {
        guard var email = userData.email, var password = userData.password, var username = userData.username else {
            return .failure(.noUserData)
        }
        
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let usernameResult = validateUsername(username)
        if usernameResult != nil {
            return .failure(usernameResult!)
        }
        let emailResult = validateEmail(email)
        if emailResult != nil {
            return .failure(emailResult!)
        }
        let passwordResult = validatePassword(password)
        if passwordResult != nil {
            return .failure(passwordResult!)
        }
        
        return .success((email: email, password: password, username: username))
    }
    
    private func validateUsername(_ username: String) -> RegisterValidationError? {
        if username == "" {
            return .noUsername
        }
        for forbiddenChar in RegisterService.USERNAME_FORBIDDEN_CHARACTERS {
            if username.contains(forbiddenChar) {
                return .forbiddenCharacterInUsername(forbiddenChar)
            }
        }
        if username.characters.count > RegisterService.USERNAME_MAX_LENGTH {
            return .tooLongUsername
        }
        return nil
    }
    
    private func validateEmail(_ email: String) -> RegisterValidationError? {
        if email == "" {
            return .noEmail
        }
        if email.characters.count > RegisterService.EMAIL_MAX_LENGTH {
            return .tooLongEmail
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: email) {
            return .invalidEmail
        }
        
        return nil
    }
    
    private func validatePassword(_ password: String) -> RegisterValidationError? {
        if password == "" {
            return .noPassword
        }
        if password.characters.count < RegisterService.PASSWORD_MIN_LENGTH {
            return .tooShortPassword
        }
        if password.characters.count > RegisterService.PASSWORD_MAX_LENGTH {
            return .tooLongPassword
        }
        
        let numberRegEx  = ".*[0-9]+.*"
        let passwordNumberTest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        if !passwordNumberTest.evaluate(with: password) {
            return .noNumberInPassword
        }
        
        let capitalRegEx  = ".*[A-Z]+.*"
        let passwordCapitalTest = NSPredicate(format:"SELF MATCHES %@", capitalRegEx)
        if !passwordCapitalTest.evaluate(with: password) {
            return .noCapitalInPassword
        }
        
        return nil
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
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .networkError:
                    onComplete(.failure(.noInternet))
                case .tooManyRequests:
                    onComplete(.failure(.tooManyRequests))
                case .emailAlreadyInUse:
                    onComplete(.failure(.emailAlreadyInUse))
                case .invalidEmail:
                    onComplete(.failure(.invalidEmail))
                case .weakPassword:
                    onComplete(.failure(.passwordTooWeak))
                default:
                    onComplete(.failure(.unknown))
                }
                ListsUser.instance.deleteLoggedInUserBeforeFullyCreated()
            } else if let user = user{
                self.addUserDataToDatabase(user.uid, withUsername: username, withOnComplete: onComplete)
            } else {
                ListsUser.instance.deleteLoggedInUserBeforeFullyCreated()
                onComplete(.failure(.unknown))
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
                case .permissionDenied:
                    onComplete(.failure(.permissionDenied))
                case .unknown:
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
    case userDisabled
    case invalidEmail
    case invalidPassword
    case noInternet
    case userTokenExpired
    case tooManyRequests
    case invalidAPIKey
    case firebaseError
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

class LoginService {
 
    static let instance = LoginService()
    
    private init() {}
    
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
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .userNotFound:
                    onComplete(.failure(.userNotFound))
                case .userDisabled:
                    onComplete(.failure(.userDisabled))
                case .wrongPassword:
                    onComplete(.failure(.userNotFound))
                case .invalidEmail:
                    onComplete(.failure(.invalidEmail))
                case .networkError:
                    onComplete(.failure(.noInternet))
                case .userTokenExpired:
                    onComplete(.failure(.userTokenExpired))
                case .tooManyRequests:
                    onComplete(.failure(.tooManyRequests))
                case .invalidAPIKey:
                    onComplete(.failure(.invalidAPIKey))
                case .appNotAuthorized:
                    onComplete(.failure(.invalidAPIKey))
                case .keychainError:
                    onComplete(.failure(.unknown))
                case .internalError:
                    onComplete(.failure(.firebaseError))
                default:
                    onComplete(.failure(.unknown))
                }
            } else {
                onComplete(.success)
            }
        }
    }
    
    func reload(_ onComplete: @escaping (LoginServiceResult)->()) {
        Auth.auth().currentUser?.reload(completion: { error in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .userNotFound:
                    onComplete(.failure(.userNotFound))
                case .userDisabled:
                    onComplete(.failure(.userDisabled))
                case .wrongPassword:
                    onComplete(.failure(.userNotFound))
                case .invalidEmail:
                    onComplete(.failure(.invalidEmail))
                case .networkError:
                    onComplete(.failure(.noInternet))
                case .userTokenExpired:
                    onComplete(.failure(.userTokenExpired))
                case .tooManyRequests:
                    onComplete(.failure(.tooManyRequests))
                case .invalidAPIKey:
                    onComplete(.failure(.invalidAPIKey))
                case .appNotAuthorized:
                    onComplete(.failure(.invalidAPIKey))
                case .keychainError:
                    onComplete(.failure(.unknown))
                case .internalError:
                    onComplete(.failure(.firebaseError))
                default:
                    onComplete(.failure(.unknown))
                }
            } else {
                onComplete(.success)
            }
        })
    }
}



enum VerificationResult {
    case success
    case failure(VerificationError)
}

enum VerificationError {
    case invalidEmail
    case userNotFound
    case firebaseError
    case userDisabled
    case tooManyRequests
    case noInternet
    case unknown
}

class VerificationService {
    
    static let instance = VerificationService()
    
    private init() {}
    
    func sendVerification(_ onComplete: @escaping (VerificationResult)->()) {
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidRecipientEmail:
                    onComplete(.failure(.invalidEmail))
                case .invalidEmail:
                    onComplete(.failure(.invalidEmail))
                case .userNotFound:
                    onComplete(.failure(.userNotFound))
                case .networkError:
                    onComplete(.failure(.noInternet))
                case .userDisabled:
                    onComplete(.failure(.userDisabled))
                case .tooManyRequests:
                    onComplete(.failure(.tooManyRequests))
                case .appNotAuthorized:
                    onComplete(.failure(.firebaseError))
                case .internalError:
                    onComplete(.failure(.firebaseError))
                case .invalidSender:
                    onComplete(.failure(.firebaseError))
                case .invalidMessagePayload:
                    onComplete(.failure(.firebaseError))
                default:
                    onComplete(.failure(.unknown))
                }
            } else {
                onComplete(.success)
            }
        })
    }
}

enum ForgotPasswordResult {
    case success
    case failure(ForgotPasswordError)
}

enum ForgotPasswordError {
    case invalidEmail
    case userNotFound
    case firebaseError
    case userDisabled
    case tooManyRequests
    case noInternet
    case unknown
}

enum ForgotPasswordValidationResult {
    case success(String)
    case failure(ForgotPasswordValidationError)
}

enum ForgotPasswordValidationError {
    case noEmail
}

class ForgotPasswordService {
    
    static let instance = ForgotPasswordService()
    
    private init() {}
    
    func validate(_ email: String?) -> ForgotPasswordValidationResult {
        guard var email = email else {
            return .failure(.noEmail)
        }
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email == "" {
            return .failure(.noEmail)
        }
        
        return .success(email)
    }
    
    func sendRequest(_ email: String, withOnComplete onComplete: @escaping (ForgotPasswordResult)->()) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .invalidRecipientEmail:
                    onComplete(.failure(.invalidEmail))
                case .invalidEmail:
                    onComplete(.failure(.invalidEmail))
                case .userNotFound:
                    onComplete(.failure(.userNotFound))
                case .networkError:
                    onComplete(.failure(.noInternet))
                case .userDisabled:
                    onComplete(.failure(.userDisabled))
                case .tooManyRequests:
                    onComplete(.failure(.tooManyRequests))
                case .appNotAuthorized:
                    onComplete(.failure(.firebaseError))
                case .internalError:
                    onComplete(.failure(.firebaseError))
                case .invalidSender:
                    onComplete(.failure(.firebaseError))
                case .invalidMessagePayload:
                    onComplete(.failure(.firebaseError))
                default:
                    onComplete(.failure(.unknown))
                }
            } else {
                onComplete(.success)
            }
        })
    }
}














