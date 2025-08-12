//
//  ServicesAssemblerTests.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 12/8/25.
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class ServicesAssemblerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ServicesAssembler.cleanup()
    }
    
    override func tearDown() {
        ServicesAssembler.cleanup()
        super.tearDown()
    }
    
    func testBitcoinRateServiceSingleton() {
        // Given & When
        let service1 = ServicesAssembler.bitcoinRateService()
        let service2 = ServicesAssembler.bitcoinRateService()
        
        // Then
        XCTAssertTrue(service1 === service2, "BitcoinRateService should be a singleton")
    }
    
    func testAnalyticsServiceSingleton() {
        // Given & When
        let service1 = ServicesAssembler.analyticsService()
        let service2 = ServicesAssembler.analyticsService()
        
        // Then
        XCTAssertTrue(service1 === service2, "AnalyticsService should be a singleton")
    }
    
    func testModuleInitialization() {
        // Given
        let initialCount = ServicesAssembler.subscriptionCount
        
        // When
        ServicesAssembler.initializeModules()
        
        // Then
        XCTAssertGreaterThan(ServicesAssembler.subscriptionCount, initialCount, "At least one subscription should be initialized")
        XCTAssertGreaterThanOrEqual(ServicesAssembler.subscriptionCount, 50, "50+ module subscriptions should be initialized")
    }
    
    func testRatePublisherDistribution() {
        // Given
        var receivedCount = 0
        let expectation = XCTestExpectation(description: "Multiple subscribers receive an update")
        expectation.expectedFulfillmentCount = 3 // Expecting 3 fulfillments
        var cancellables = Set<AnyCancellable>()
        
        // Creating 3 test subscriptions
        ServicesAssembler.bitcoinRatePublisher
            .sink { _ in
                receivedCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        ServicesAssembler.bitcoinRatePublisher
            .sink { _ in
                receivedCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        ServicesAssembler.bitcoinRatePublisher
            .sink { _ in
                receivedCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        // Sending an event to the publisher
        ServicesAssembler.bitcoinRateUpdateSubject.send(50000)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedCount, 3, "All 3 subscribers should have received the update")
    }
    
    func testScalabilityTo50Modules() {
        // Given
        let moduleCount = 50
        var receivedUpdates = 0
        let expectation = XCTestExpectation(description: "50 modules receive an update")
        expectation.expectedFulfillmentCount = moduleCount
        var cancellables = Set<AnyCancellable>()

        // Creating 50 subscriptions
        for i in 0..<moduleCount {
            ServicesAssembler.bitcoinRatePublisher
                .sink { rate in
                    receivedUpdates += 1
                    expectation.fulfill()
                    XCTAssertEqual(rate, 75000, "Module \(i) should have received the correct rate")
                }
                .store(in: &cancellables)
        }
        
        // When
        ServicesAssembler.bitcoinRateUpdateSubject.send(75000)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedUpdates, moduleCount, "All 50 modules should have received the update")
    }
    
    func testAnalyticsIntegration() {
        // Given
        ServicesAssembler.initializeModules()
        let analyticsService = ServicesAssembler.analyticsService() as? AnalyticsServiceImpl
        let initialEventCount = analyticsService?.getEvents(name: "bitcoin_rate_update", from: nil, to: nil).count ?? 0
        
        // When
        ServicesAssembler.bitcoinRateUpdateSubject.send(65000)
        
        // Then
        let expectation = XCTestExpectation(description: "Analytics service processes an event")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newEventCount = analyticsService?.getEvents(name: "bitcoin_rate_update", from: nil, to: nil).count ?? 0
            XCTAssertEqual(newEventCount, initialEventCount + 1, "Analytics should have tracked the rate update")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCleanup() {
        // Given
        ServicesAssembler.initializeModules()
        XCTAssertGreaterThan(ServicesAssembler.subscriptionCount, 0)
        
        // When
        ServicesAssembler.cleanup()
        
        // Then
        XCTAssertEqual(ServicesAssembler.subscriptionCount, 0, "All subscriptions should be cancelled")
    }
}
