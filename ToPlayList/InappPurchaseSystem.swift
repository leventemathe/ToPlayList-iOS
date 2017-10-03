//
//  InappPurchaseSystem.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 09. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import StoreKit

protocol InappPurchaseSystemDelegate: class {
    
    func didReceiveProducts(_ products: [InappPurchaseProduct])
    func productRequestFailed(with error: Error)
    func productPurchased(_ product: String)
    func productPurchaseFailed(_ product: String)
    func productRestored(_ product: String)
    func productVerification(result: InappPurchaseVerificationResult)
}

enum InappPurchaseVerificationResult {
    case validReceipt
    case invalidReceipt
    case receiptTaken
    case error(InappPurchaseVerificationError)
}

enum InappPurchaseVerificationError {
    case receiptMissing
    case server
    case network
}

struct InappPurchaseProduct {
    
    let id: String
    let price: String
}

extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
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
                delegate?.didReceiveProducts(createProducts())
            }
        }
    }

    private func createProducts() -> [InappPurchaseProduct] {
        return products.map({ InappPurchaseProduct(id: $0.productIdentifier, price: $0.localizedPrice()) })
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
        delegate?.didReceiveProducts(createProducts())
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
        print("User purchased product id: \(transaction.payment.productIdentifier) at : \(String(describing: transaction.transactionDate))")
        queue.finishTransaction(transaction)
        self.delegate?.productPurchased(transaction.payment.productIdentifier)
        verifyReceipt { result in
            switch result {
            case .validReceipt:
                self.setReceipt()
            default:
                break
            }
            self.delegate?.productVerification(result: result)
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
    
    func verifyReceipt(_ onComplete: @escaping (InappPurchaseVerificationResult)->()) {
        guard let receipt = loadReceipt() else {
            onComplete(.error(.receiptMissing))
            return
        }
        InappPurchaseService.instance.verify(receipt: receipt, withOnComplete: { result in
            switch result {
            case .success(let success):
                switch success {
                case .success:
                    onComplete(.validReceipt)
                case .invalidReceipt:
                    onComplete(.invalidReceipt)
                case .receiptTaken:
                    onComplete(.receiptTaken)
                }
            case .error(let error):
                switch error {
                case .network:
                    onComplete(.error(.network))
                case .server, .json, .unauthorized, . appleServer, .noReceipt:
                    onComplete(.error(.server))
                }
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
    
    func setReceipt() {
        
    }
}
