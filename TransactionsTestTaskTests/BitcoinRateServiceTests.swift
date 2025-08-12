//
//  BitcoinRateServiceTests.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 12/8/25.
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class BitcoinRateServiceTests: XCTestCase {
    
    var sut: BitcoinRateServiceImpl!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = BitcoinRateServiceImpl()
        cancellables = Set<AnyCancellable>()
        ServicesAssembler.cleanup()
    }
    
    override func tearDown() {
        sut.stopMonitoring()
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testStartMonitoringSendsRateUpdateToPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Publisher received a rate update")
        var receivedRate: Double?
        
        ServicesAssembler.bitcoinRatePublisher
            .sink { rate in
                receivedRate = rate
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.startMonitoring()
        
        // Then
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(receivedRate)
        XCTAssertGreaterThan(receivedRate ?? 0, 0)
    }
    
    func testGetCurrentRateAfterMonitoring() {
        // Given
        let expectation = XCTestExpectation(description: "The rate was received and saved")
        
        ServicesAssembler.bitcoinRatePublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.startMonitoring()
        wait(for: [expectation], timeout: 10.0)
        
        // When
        let currentRate = sut.getCurrentRate()
        
        // Then
        XCTAssertNotNil(currentRate)
        XCTAssertGreaterThan(currentRate ?? 0, 0)
    }

    func testStopMonitoring() {
        // Given
        sut.startMonitoring()
        
        // When
        sut.stopMonitoring()
        
        // Then
        XCTAssertTrue(true, "stopMonitoring() should not cause a crash")
    }
}
