//
//  TransactionCategory.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

enum TransactionCategory: String, CaseIterable {
    case groceries
    case taxi
    case electronics
    case restaurant
    case other
    
    var displayName: String {
        switch self {
        case .groceries: return "Groceries"
        case .taxi: return "Taxi"
        case .electronics: return "Electronics"
        case .restaurant: return "Restaurant"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .groceries: return "cart.fill"
        case .taxi: return "car.fill"
        case .electronics: return "laptopcomputer"
        case .restaurant: return "fork.knife"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
