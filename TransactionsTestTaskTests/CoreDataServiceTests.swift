//
//  CoreDataServiceTests.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 12/8/25.
//

import XCTest
import CoreData
@testable import TransactionsTestTask

final class CoreDataServiceTests: XCTestCase {
    
    var sut: CoreDataService!
    var mockStack: MockCoreDataStack!
    
    override func setUp() {
        super.setUp()
        mockStack = MockCoreDataStack()
        sut = CoreDataService()
    }
    
    override func tearDown() {
        sut = nil
        mockStack = nil
        super.tearDown()
    }
    
    func testSaveBitcoinRate() {
        // Given
        let rate = 50000.0
        
        // When
        sut.saveBitcoinRate(rate)
        
        // Then
        let savedRate = sut.getLatestBitcoinRate()
        XCTAssertNotNil(savedRate)
        XCTAssertEqual(savedRate, rate)
    }
    
    func testSaveTransaction() {
        // Given
        let transaction = Transaction(
            id: UUID(),
            amount: 0.5,
            category: .groceries,
            date: Date(),
            type: .expense
        )
        
        // When
        sut.saveTransaction(transaction)
        
        // Then
        let transactions = sut.fetchTransactions(page: 0, pageSize: 10)
        XCTAssertTrue(transactions.contains { $0.id == transaction.id })
    }
    
    func testFetchTransactionsPagination() {
        // Given
        for i in 0..<25 {
            let transaction = Transaction(
                id: UUID(),
                amount: Decimal(i),
                category: .other,
                date: Date(timeIntervalSinceNow: TimeInterval(-i * 3600)),
                type: .expense
            )
            sut.saveTransaction(transaction)
        }
        
        // When
        let page1 = sut.fetchTransactions(page: 0, pageSize: 20)
        let page2 = sut.fetchTransactions(page: 1, pageSize: 20)
        
        // Then
        XCTAssertEqual(page1.count, 20)
        XCTAssertLessThanOrEqual(page2.count, 5)
    }
    
    func testGetTotalBalance() {
        // Given
        let income = Transaction(
            id: UUID(),
            amount: 100,
            category: .other,
            date: Date(),
            type: .income
        )
        let expense = Transaction(
            id: UUID(),
            amount: 30,
            category: .groceries,
            date: Date(),
            type: .expense
        )
        
        // When
        sut.saveTransaction(income)
        sut.saveTransaction(expense)
        let balance = sut.getTotalBalance()
        
        // Then
        XCTAssertEqual(balance, 70)
    }
    
    func testBalanceNeverNegative() {
        // Given
        let expense = Transaction(
            id: UUID(),
            amount: 100,
            category: .taxi,
            date: Date(),
            type: .expense
        )
        
        // When
        sut.saveTransaction(expense)
        let balance = sut.getTotalBalance()
        
        // Then
        XCTAssertEqual(balance, 0) // Should be 0, not negative
    }
}

// Mock CoreDataStack for testing
class MockCoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsTestTask")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        return container
    }()
}
