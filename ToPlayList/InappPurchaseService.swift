//
//  InappPurchaseService.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Alamofire

enum InappPurchasesServiceResult<T> {
    case success(T)
    case error(InappPurchasesServiceError)
}

enum InappPurchasesServiceSuccess {
    case success
    case invalidReceipt
    case receiptTaken
}

enum InappPurchasesServiceError {
    case network
    case server
    case json
    case unauthorized
    case noReceipt
    case appleServer
}

class InappPurchaseService {
    
    static let instance = InappPurchaseService()
    
    private let baseURL = "\(Configuration.instance.firebaseCloudFunctionsURL)/app"
    
    private init() {}
    
    func getProductIDs(_ onComplete: @escaping (InappPurchasesServiceResult<[String]>)->()) {
        let url = baseURL + "/productIDs"
        ListsUser.getToken { token in
            guard let token = token else {
                onComplete(.error(.network))
                return
            }
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(url, headers: headers).validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? JSON {
                        guard let ids = json as? [String] else {
                            onComplete(.error(.server))
                            return
                        }
                        onComplete(.success(ids))
                    } else {
                        onComplete(.error(.json))
                    }
                case .failure(_):
                    if !self.isAuthorized(response) {
                        onComplete(.error(.unauthorized))
                        return
                    }
                    onComplete(.error(.server))
                }
            })
        }
    }
    
    func verify(receipt: Data, withOnComplete onComplete: @escaping (InappPurchasesServiceResult<InappPurchasesServiceSuccess>)->()) {
        let url = baseURL + "/verifyReceipt"
        ListsUser.getToken { token in
            guard let token = token else {
                onComplete(.error(.network))
                return
            }
            let headers = ["Authorization": "Bearer \(token)",
                           "Content-Type": "application/json"]
            let params = ["data": receipt.base64EncodedString()]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
                if !self.isAuthorized(response) {
                    onComplete(.error(.unauthorized))
                    return
                }
                guard let json = response.result.value as? [String: Any] else {
                    onComplete(.error(.server))
                    return
                }
                if let success = json["success"] as? Int {
                    switch success {
                    case 0:
                        onComplete(.success(.success))
                    case 1:
                        onComplete(.success(.invalidReceipt))
                    case 2:
                        onComplete(.success(.receiptTaken))
                    default:
                        onComplete(.error(.server))
                    }
                } else if let error = json["error"] as? Int {
                    switch error {
                    case 1:
                        onComplete(.error(.appleServer))
                    case 2:
                        onComplete(.error(.noReceipt))
                    default:
                        onComplete(.error(.server))
                    }
                } else {
                    onComplete(.error(.json))
                }
            })
        }
    }
    
    private func isAuthorized(_ response: DataResponse<Any>) -> Bool {
        if let statusCode = response.response?.statusCode {
            if statusCode == 403 {
                return false
            }
        }
        return true
    }
}




