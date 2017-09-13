//
//  InappPurchasesService.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Alamofire

enum InappPurchasesServiceResult {
    case success([String])
    case failure(InappPurchasesServiceError)
}

enum InappPurchasesServiceError {
    case network
    case server
}

class InappPurchasesService {
    
    static let instance = InappPurchasesService()
    
    private let baseURL = "\(Configuration.instance.firebaseCloudFunctionsURL)/app"
    
    private init() {}
    
    func getProductIDs(_ onComplete: @escaping (InappPurchasesServiceResult)->()) {
        let url = baseURL + "/productIDs"
        ListsUser.getToken({ token in
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
                    }
                case .failure(_):
                    onComplete(.failure(.server))
                }
            })
        })
    }
}
