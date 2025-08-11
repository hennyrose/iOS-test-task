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
    
    func addTransaction(_ transaction: Transaction) {
        coreDataService.saveTransaction(transaction)
        if transaction.type == .expense {
            let newBalance = balanceSubject.value - transaction.amount
            balanceSubject.send(newBalance)
        }
    }
    
    func getTransactions(page: Int, pageSize: Int = 20) -> [Transaction] {
        return coreDataService.fetchTransactions(page: page, pageSize: pageSize)
    }
    
    func getBalance() -> Decimal {
        return balanceSubject.value
    }
    
    func addToBalance(_ amount: Decimal) {
        let newBalance = balanceSubject.value + amount
        balanceSubject.send(newBalance)
        
        let transaction = Transaction(
            id: UUID(),
            amount: amount,
            category: .other,
            date: Date(),
            type: .income
        )
        coreDataService.saveTransaction(transaction)
    }
}
