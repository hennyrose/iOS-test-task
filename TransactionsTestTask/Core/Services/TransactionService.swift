//
//  TransactionService.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import Foundation
import Combine

protocol TransactionServiceProtocol {
    func addTransaction(_ transaction: Transaction)
    func getTransactions(page: Int, pageSize: Int) -> [Transaction]
    func getBalance() -> Decimal
    func addToBalance(_ amount: Decimal)
    var balancePublisher: AnyPublisher<Decimal, Never> { get }
}

final class TransactionService: TransactionServiceProtocol {
    static let shared = TransactionService()
    
    private let coreDataService = CoreDataService()
    private let balanceSubject = CurrentValueSubject<Decimal, Never>(0)
    
    var balancePublisher: AnyPublisher<Decimal, Never> {
        balanceSubject.eraseToAnyPublisher()
    }
    
    private init() {
        loadBalance()
    }
    
    private func loadBalance() {
        let balance = coreDataService.getTotalBalance()
        balanceSubject.send(balance)
    }
    
    func addTransaction(_ transaction: Transaction) {
        coreDataService.saveTransaction(transaction)
        
        loadBalance()
    }
    
    func getTransactions(page: Int, pageSize: Int = 20) -> [Transaction] {
        return coreDataService.fetchTransactions(page: page, pageSize: pageSize)
    }
    
    func getBalance() -> Decimal {
        let balance = coreDataService.getTotalBalance()
        balanceSubject.send(balance)
        return balance
    }
    
    func addToBalance(_ amount: Decimal) {
        let transaction = Transaction(
            id: UUID(),
            amount: amount,
            category: .other,
            date: Date(),
            type: .income
        )
        
        coreDataService.saveTransaction(transaction)
        
        loadBalance()
    }
}
