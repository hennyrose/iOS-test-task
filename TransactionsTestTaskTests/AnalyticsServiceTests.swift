//
//  AnalyticsServiceTests.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 12/8/25.
//

import XCTest
@testable import TransactionsTestTask

final class AnalyticsServiceTests: XCTestCase {
    
    var sut: AnalyticsServiceImpl!
    
    override func setUp() {
        super.setUp()
        sut = AnalyticsServiceImpl()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testTrackEvent() {
        // Given
        let eventName = "test_event"
        let parameters = ["key": "value", "amount": "100"]
        
        // When
        sut.trackEvent(name: eventName, parameters: parameters)
        
        // Then
        let events = sut.getEvents(name: eventName, from: nil, to: nil)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, eventName)
        XCTAssertEqual(events.first?.parameters, parameters)
    }
    
    func testTrackMultipleEvents() {
        // Given
        let events = [
            ("event1", ["param1": "value1"]),
            ("event2", ["param2": "value2"]),
            ("event3", ["param3": "value3"])
        ]
        
        // When
        for (name, params) in events {
            sut.trackEvent(name: name, parameters: params)
        }
        
        // Then
        let allEvents = sut.getEvents(name: nil, from: nil, to: nil)
        XCTAssertEqual(allEvents.count, 3)
    }
    
    func testGetEventsByName() {
        // Given
        sut.trackEvent(name: "event1", parameters: [:])
        sut.trackEvent(name: "event2", parameters: [:])
        sut.trackEvent(name: "event1", parameters: [:])
        
        // When
        let filteredEvents = sut.getEvents(name: "event1", from: nil, to: nil)
        
        // Then
        XCTAssertEqual(filteredEvents.count, 2)
        XCTAssertTrue(filteredEvents.allSatisfy { $0.name == "event1" })
    }
    
    func testGetEventsByDateRange() {
        // Given
        let now = Date()
        let yesterday = Date(timeIntervalSinceNow: -86400)
        let tomorrow = Date(timeIntervalSinceNow: 86400)
        
        sut.trackEvent(name: "today_event", parameters: [:])
        
        // When
        let eventsFromYesterday = sut.getEvents(name: nil, from: yesterday, to: nil)
        let eventsFromTomorrow = sut.getEvents(name: nil, from: tomorrow, to: nil)
        
        // Then
        XCTAssertGreaterThan(eventsFromYesterday.count, 0)
        XCTAssertEqual(eventsFromTomorrow.count, 0)
    }
    
    func testTrackBitcoinRateUpdateEvent() {
        // Given
        let rate = 45678.90
        
        // When
        sut.trackEvent(
            name: "bitcoin_rate_update",
            parameters: ["rate": String(format: "%.2f", rate)]
        )
        
        // Then
        let events = sut.getEvents(name: "bitcoin_rate_update", from: nil, to: nil)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.parameters["rate"], "45678.90")
    }
}
