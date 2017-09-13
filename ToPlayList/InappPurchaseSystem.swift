//
//  InappPurchaseSystem.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import StoreKit

class InappPurchaseSystem: NSObject, SKProductsRequestDelegate {
    
    static let instance = InappPurchaseSystem()
    
    private override init() {}
    
    var premiumID = "com.levente.mathe.dev.ToPlayList.Premium"
    
    var products = [SKProduct]()
    
    func loadProducts() {
        let ids = Set([premiumID])
        let request = SKProductsRequest(productIdentifiers: ids)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        for product in products {
            print(product.productIdentifier)
        }
        // TODO: app connected, enable purchase
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
            // TODO: handle error
        }
    }
}
