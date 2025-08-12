//
//  AddTransactionViewModel.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import Foundation
import Combine

extension Notification.Name {
    static let transactionAdded = Notification.Name("transactionAdded")
}

final class AddTransactionViewModel {
    @Published var amount: String = ""
    @Published var selectedCategory: TransactionCategory = .other
    @Published private(set) var isValid: Bool = false
    
    private let transactionService: TransactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(transactionService: TransactionServiceProtocol) {
        self.transactionService = transactionService
        
        $amount
            .map { amount in
                guard !amount.isEmpty,
                      let decimal = Decimal(string: amount),
                      decimal > 0 else {
                    return false
                }
                return true
            }
            .assign(to: &$isValid)
    }
    
    func addTransaction() -> Bool {
        guard let decimalAmount = Decimal(string: amount) else { return false }
        
        if let service = transactionService as? TransactionService {
            let currentBalance = service.getBalance()
            if decimalAmount > currentBalance {
                return false
            }
        }
        
        let transaction = Transaction(
            id: UUID(),
            amount: decimalAmount,
            category: selectedCategory,
            date: Date(),
            type: .expense
        )
        
        transactionService.addTransaction(transaction)
        NotificationCenter.default.post(name: .transactionAdded, object: nil)
        return true
    }
}
