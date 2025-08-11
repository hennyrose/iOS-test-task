//
//  Transaction.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import Foundation

struct Transaction {
    let id: UUID
    let amount: Decimal
    let category: TransactionCategory
    let date: Date
    let type: TransactionType
    
    enum TransactionType {
        case income
        case expense
    }
}
