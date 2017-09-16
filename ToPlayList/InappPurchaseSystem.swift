//
//  InappPurchaseSystem.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import StoreKit

protocol InappPurchaseSystemDelegate: class {
    
    func didReceiveProducts(_ products: [String])
    func productRequestFailed(with error: Error)
}

class InappPurchaseSystem: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let instance = InappPurchaseSystem()
    
    private override init() {}
    
    // TODO: add this to config, or get from Firebase
    var premiumID = "com.levente.mathe.dev.ToPlayList.Premium"
    
    var products = [SKProduct]()
    
    weak var delegate: InappPurchaseSystemDelegate? {
        didSet {
            if products.count > 0 {
                delegate?.didReceiveProducts(products.map({ $0.productIdentifier }))
            }
        }
    }
    
    func loadProducts() {
        let ids = Set([premiumID])
        let request = SKProductsRequest(productIdentifiers: ids)
        request.delegate = self
        request.start()
    }
    
    // request.start() was succesful
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        for product in products {
            print("***************")
            print(product.productIdentifier)
        }
        delegate?.didReceiveProducts(products.map({ $0.productIdentifier }))
    }
    
    // request.start() failed
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("***************")
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
            // TODO: handle error here, instead of delegate
            delegate?.productRequestFailed(with: error)
        }
    }
    
    // called from outside to initiate purchase of a product
    func purchase(product: String) {
        for prod in products {
            if let prodName = prod.productIdentifier.split(separator: ".").last {
                if prodName == product {
                    purchase(product: prod)
                    return
                }
            }
        }
    }
    
    private func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // this is called whenever something happens with a payment transaction
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Updated transactions")
    }
}
