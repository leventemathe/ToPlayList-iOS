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
    case failure(InappPurchasesServiceError)
}

enum InappPurchasesServiceError {
    case network
    case server
    case json
}

class InappPurchaseService {
    
    static let instance = InappPurchaseService()
    
    private let baseURL = "\(Configuration.instance.firebaseCloudFunctionsURL)/app"
    
    private init() {}
    
    func getProductIDs(_ onComplete: @escaping (InappPurchasesServiceResult<[String]>)->()) {
        let url = baseURL + "/productIDs"
        ListsUser.getToken { token in
            guard let token = token else {
                onComplete(.failure(.network))
                return
            }
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(url, headers: headers).validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? JSON {
                        guard let ids = json as? [String] else {
                            onComplete(.failure(.server))
                            return
                        }
                        onComplete(.success(ids))
                    } else {
                        onComplete(.failure(.json))
                    }
                case .failure(_):
                    onComplete(.failure(.server))
                }
            })
        }
    }
    
    func verify(receipt: Data, withOnComplete onComplete: @escaping (InappPurchasesServiceResult<Bool>)->()) {
        let url = baseURL + "/verifyReceipt"
        ListsUser.getToken { token in
            guard let token = token else {
                onComplete(.failure(.network))
                return
            }
            let headers = ["Authorization": "Bearer \(token)",
                           "Content-Type": "application/json"]
            let params = ["data": receipt.base64EncodedString()]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        guard let success = json["success"] as? Bool else {
                            onComplete(.failure(.server))
                            return
                        }
                        onComplete(.success(success))
                    } else {
                        onComplete(.failure(.json))
                    }
                case .failure(_):
                    onComplete(.failure(.server))
                }
            })
        }
    }
}




