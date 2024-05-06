//
//  IAP.swift
//  Timenote
//
//  Created by Moshe Assaban on 6/2/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import StoreKit

enum InAppPurchasePack: String {
    case twentyPoints       = "twenty.bobeepoints"
    case fiftyPoints        = "fifty.bobeepoints"
    case hundredtenPoints   = "hundredten.bobeepoints"
    case monthlySub         = "bobeeplus.monhtly"
    case semiYearlySub      = "bobeeplus.semiyearly"
}

@objc protocol IAPManagerDelegate {
    
    /* Fetch Product */
    
    @objc optional func didFail(error: Error)
    @objc optional func didNotFoundProducts()
    @objc optional func didFoundProduct(product: SKProduct)
    @objc optional func didFoundProducts(products: [SKProduct])
    
    /* Payment Product */
    @objc optional func didCancel()
    @objc optional func paymentSuccessfull()
    @objc optional func productRestored(_ original: SKPaymentTransaction)
}

class IAPManager: NSObject {
    
    private static let shared = IAPManager()

    var delegate: IAPManagerDelegate!
    var productRequest: SKProductsRequest!
    
    func fetchProduct(identifier: String) {
        
        productRequest?.cancel()
        productRequest = SKProductsRequest(productIdentifiers: [identifier])
        productRequest.delegate = self
        productRequest.start()
    }
    
    func fetchProducts(identifiers: [InAppPurchasePack]) {
        
        productRequest?.cancel()
        productRequest = SKProductsRequest(productIdentifiers: Set(identifiers.map {$0.rawValue}))
        productRequest.delegate = self
        productRequest.start()
    }
    
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        
        DispatchQueue.main.async {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restoreProducts() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension IAPManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if let product = response.products.first, response.products.count == 1 {
            self.delegate.didFoundProduct?(product: product)
        } else if response.products.count > 1 {
            self.delegate.didFoundProducts?(products: response.products)
        } else {
            self.delegate.didNotFoundProducts?()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
        self.delegate.didFail?(error: error)
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        self.delegate.didCancel?()
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.productRestored?(queue.transactions.first!)
        print("Finish")
    }
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        self.delegate.paymentSuccessfull?()
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        if let transaction = transaction.original {
            self.delegate.productRestored?(transaction)
        }
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                self.delegate.didFail?(error: transaction.error!)
            }
        }
    }
}
