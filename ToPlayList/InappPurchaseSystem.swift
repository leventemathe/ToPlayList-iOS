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
    func productPurchased(_ product: String)
    func productPurchaseFailed(_ product: String)
    func productRestored(_ product: String)
}

class InappPurchaseSystem: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let instance = InappPurchaseSystem()
    
    private override init() {}
    
    // TODO: add this to config, or get from Firebase
    static let PREMIUM_ID = "com.levente.mathe.dev.ToPlayList.Premium"
    
    var products = [SKProduct]()
    
    weak var delegate: InappPurchaseSystemDelegate? {
        didSet {
            if products.count > 0 {
                delegate?.didReceiveProducts(products.map({ $0.productIdentifier }))
            }
        }
    }
    
    func loadProducts() {
        let ids = Set([InappPurchaseSystem.PREMIUM_ID])
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
            if prod.productIdentifier == product {
                purchase(product: prod)
                return
            }
        }
    }
    
    private func purchase(product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        /*
        if case .dev = Configuration.instance.state {
            payment.simulatesAskToBuyInSandbox = true
        } else {
            payment.simulatesAskToBuyInSandbox = false
        }
         */
        SKPaymentQueue.default().add(payment)
    }
    
    // this is called whenever something happens with a payment transaction
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Updated transactions")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue, with: transaction.error)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        verifyReceipt {
            queue.finishTransaction(transaction)
            self.delegate?.productPurchased(transaction.payment.productIdentifier)
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        delegate?.productRestored(transaction.payment.productIdentifier)
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue, with error: Error?) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier), with error: \(error.debugDescription)")
        queue.finishTransaction(transaction)
        delegate?.productPurchaseFailed(transaction.payment.productIdentifier)
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
    
    // TODO handle error, add return enum
    private func verifyReceipt(_ onComplete: @escaping ()->()) {
        guard let receipt = loadReceipt() else {
            onComplete()
            return
        }
        InappPurchaseService.instance.verify(receipt: receipt, withOnComplete: { result in
            switch result {
            case .success(let success):
                print(success)
                onComplete()
            case .failure(let error):
                print(error)
                onComplete()
            }
        })
    }
    
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        do {
            let receipt = try Data(contentsOf: url)
            return receipt
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}
